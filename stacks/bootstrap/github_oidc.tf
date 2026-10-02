# GitHub Actions se autentica en AWS con OIDC: no hay llaves guardadas en GitHub.
# Cada repositorio solo puede asumir SU rol, y solo desde contextos concretos.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

locals {
  infra_subjects = [
    "repo:${var.github_owner}/${var.infra_repo}:ref:refs/heads/main",
    "repo:${var.github_owner}/${var.infra_repo}:environment:infra",
    "repo:${var.github_owner}/${var.infra_repo}:pull_request",
  ]

  app_subjects = [
    "repo:${var.github_owner}/${var.app_repo}:ref:refs/heads/main",
    "repo:${var.github_owner}/${var.app_repo}:environment:staging",
    "repo:${var.github_owner}/${var.app_repo}:environment:prod",
  ]
}

# ---------- Rol del pipeline de infraestructura ----------
data "aws_iam_policy_document" "infra_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.infra_subjects
    }
  }
}

resource "aws_iam_role" "gha_infra" {
  name               = "${var.project}-gha-infra"
  description        = "Rol que asume el pipeline de IaC del repo ${var.infra_repo}"
  assume_role_policy = data.aws_iam_policy_document.infra_trust.json
}

# Decisión consciente: el pipeline de IaC crea VPC, EKS, IAM, ALB, WAF y DNS,
# así que necesita permisos amplios. El control está en la confianza: solo el
# repo de infraestructura puede asumir este rol. En producción se acotaría con
# un permission boundary.
resource "aws_iam_role_policy_attachment" "gha_infra_admin" {
  role       = aws_iam_role.gha_infra.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ---------- Rol del pipeline de la aplicación ----------
data "aws_iam_policy_document" "app_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.app_subjects
    }
  }
}

resource "aws_iam_role" "gha_app" {
  name               = "${var.project}-gha-app"
  description        = "Rol que asume el pipeline de la app del repo ${var.app_repo}"
  assume_role_policy = data.aws_iam_policy_document.app_trust.json
}

# Mínimo privilegio: subir imágenes a SU repositorio de ECR, leer el contrato de
# infraestructura en Parameter Store y conectarse al clúster. No crea infraestructura.
data "aws_iam_policy_document" "app_permissions" {
  statement {
    sid       = "EcrLogin"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "EcrPushPull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = ["arn:aws:ecr:${var.region}:${local.account_id}:repository/${var.project}"]
  }

  statement {
    sid = "ReadInfraContract"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = ["arn:aws:ssm:${var.region}:${local.account_id}:parameter/${var.project}/*"]
  }

  statement {
    sid       = "DescribeCluster"
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:aws:eks:${var.region}:${local.account_id}:cluster/${var.project}*"]
  }
}

resource "aws_iam_role_policy" "gha_app" {
  name   = "deploy"
  role   = aws_iam_role.gha_app.id
  policy = data.aws_iam_policy_document.app_permissions.json
}
