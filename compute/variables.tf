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
  type    = string
  default = "../01-network/terraform.tfstate"
}

variable "data_state_path" {
  type    = string
  default = "../02-data/terraform.tfstate"
}

variable "app_service_sku" {
  type    = string
  default = "B1"
}

variable "node_version" {
  type        = string
  description = "Runtime de la Web App (cámbielo según su aplicación)."
  default     = "20-lts"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2ats_v2"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "Llave pública SSH para la VM worker."
}

variable "tags" {
  type = map(string)
  default = {
    project = "landing-zone-students"
    managed = "terraform"
  }
}
