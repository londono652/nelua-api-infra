output "ecr_repository_url" {
  description = "URL del repositorio de imágenes"
  value       = aws_ecr_repository.api.repository_url
}

output "certificate_arn" {
  description = "ARN del certificado validado"
  value       = aws_acm_certificate_validation.api.certificate_arn
}

output "hostnames" {
  description = "Nombres públicos de la API"
  value = {
    prod    = "api.${var.domain}"
    staging = "api-staging.${var.domain}"
  }
}
