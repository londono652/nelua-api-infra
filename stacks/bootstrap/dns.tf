# Zona DNS del dominio. Vive en bootstrap porque NUNCA debe recrearse:
# una zona nueva recibe name servers distintos y habría que volver a
# cambiarlos en GoDaddy.
resource "aws_route53_zone" "main" {
  name    = var.domain
  comment = "Zona publica de ${var.project} (dominio registrado en GoDaddy)"

  lifecycle {
    prevent_destroy = true
  }
}
