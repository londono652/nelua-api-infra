variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-2"
}

variable "project" {
  description = "Nombre del proyecto; prefijo de recursos y de Parameter Store"
  type        = string
  default     = "nelua-api"
}

variable "domain" {
  description = "Dominio delegado a Route 53"
  type        = string
  default     = "nelua.site"
}

variable "vpc_cidr" {
  description = "Rango de direcciones de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "nat_per_az" {
  description = "true = un NAT Gateway por zona (producción). false = uno solo (demo, más barato)"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes del clúster EKS"
  type        = string
  default     = "1.34"
}

variable "admin_user" {
  description = "Usuario IAM con acceso de administrador al clúster (kubectl desde tu equipo)"
  type        = string
  default     = "infra_admin"
}

variable "app_port" {
  description = "Puerto en el que escucha el contenedor de la API"
  type        = number
  default     = 8000
}

variable "waf_rate_limit" {
  description = "Máximo de peticiones por IP en 5 minutos antes de bloquearla"
  type        = number
  default     = 2000
}

variable "load_test_cidrs" {
  description = "IPs (formato CIDR) exentas del WAF, para el generador de la prueba de carga"
  type        = list(string)
  default     = []
}
