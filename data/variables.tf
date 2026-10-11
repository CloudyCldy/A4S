variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "prefix" {
  type    = string
  default = "lz"
}

variable "network_state_path" {
  type        = string
  description = "Ruta al estado local del stack 01-network."
  default     = "../01-network/terraform.tfstate"
}

variable "postgres_sku" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "postgres_admin_login" {
  type    = string
  default = "pgadmin"
}

variable "postgres_database_name" {
  type    = string
  default = "appdb"
}

variable "pe_postgres_ip" {
  type    = string
  default = "10.0.2.4"
}

variable "pe_blob_ip" {
  type    = string
  default = "10.0.4.4"
}

variable "entra_admin_principal_name" {
  type        = string
  description = "UPN del administrador Entra ID de PostgreSQL (p. ej. usuario@dominio.onmicrosoft.com)."
}

variable "entra_admin_object_id" {
  type        = string
  description = "Object ID del administrador Entra. Si es null se usa la identidad que ejecuta Terraform."
  default     = null
}

variable "entra_admin_principal_type" {
  type    = string
  default = "User"
}

variable "blob_container_name" {
  type    = string
  default = "uploads"
}

variable "tags" {
  type = map(string)
  default = {
    project = "landing-zone-students"
    managed = "terraform"
  }
}
