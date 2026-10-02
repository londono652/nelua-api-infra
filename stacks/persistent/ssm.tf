# Contrato entre infraestructura y aplicación: lo que este stack crea se publica
# en Parameter Store, y el pipeline de la app lo lee con permisos de solo lectura.
locals {
  parameters = {
    "ecr/repository-url"   = aws_ecr_repository.api.repository_url
    "acm/certificate-arn"  = aws_acm_certificate_validation.api.certificate_arn
    "dns/zone-id"          = data.aws_route53_zone.main.zone_id
    "dns/hostname-prod"    = "api.${var.domain}"
    "dns/hostname-staging" = "api-staging.${var.domain}"
  }
}

resource "aws_ssm_parameter" "contract" {
  for_each = local.parameters

  name  = "/${var.project}/${each.key}"
  type  = "String"
  value = each.value
}
