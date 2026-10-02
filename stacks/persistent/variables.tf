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
  description = "Dominio delegado a Route 53 (la zona la crea el stack bootstrap)"
  type        = string
  default     = "nelua.site"
}
