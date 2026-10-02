variable "region" {
  description = "Región de AWS donde vive el proyecto"
  type        = string
  default     = "us-east-2"
}

variable "project" {
  description = "Nombre del proyecto; se usa como prefijo de los recursos"
  type        = string
  default     = "nelua-api"
}

variable "domain" {
  description = "Dominio comprado en GoDaddy y delegado a Route 53"
  type        = string
  default     = "nelua.site"
}

variable "github_owner" {
  description = "Usuario u organización de GitHub dueña de los repositorios"
  type        = string
  default     = "londono652"
}

variable "infra_repo" {
  description = "Repositorio de infraestructura (Terraform)"
  type        = string
  default     = "nelua-api-infra"
}

variable "app_repo" {
  description = "Repositorio de la aplicación (FastAPI + Helm)"
  type        = string
  default     = "nelua-api-app"
}
