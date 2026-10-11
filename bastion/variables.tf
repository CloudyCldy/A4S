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

variable "bastion_sku" {
  type        = string
  description = "Basic (usa AzureBastionSubnet). Developer no usa esa subred."
  default     = "Basic"
}

variable "tags" {
  type = map(string)
  default = {
    project = "landing-zone-students"
    managed = "terraform"
  }
}
