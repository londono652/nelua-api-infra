# Contrato con el pipeline de la aplicación.
locals {
  parameters = merge(
    {
      "eks/cluster-name" = module.eks.cluster_name
    },
    {
      for env, target_group in aws_lb_target_group.api :
      "alb/target-group-arn-${env}" => target_group.arn
    },
  )
}

resource "aws_ssm_parameter" "contract" {
  for_each = local.parameters

  name  = "/${var.project}/${each.key}"
  type  = "String"
  value = each.value
}
