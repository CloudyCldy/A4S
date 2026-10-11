variable "subscription_id" {
  type        = string
  description = "ID de la suscripción Azure for Students."
}

variable "location" {
  type        = string
  description = "Región de Azure."
  default     = "eastus2"
}

variable "prefix" {
  type        = string
  description = "Prefijo corto para nombrar recursos."
  default     = "lz"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_cidrs" {
  type = object({
    app       = string
    db        = string
    vm        = string
    endpoints = string
    bastion   = string
  })
  default = {
    app       = "10.0.1.0/24"
    db        = "10.0.2.0/24"
    vm        = "10.0.3.0/24"
    endpoints = "10.0.4.0/24"
    bastion   = "10.0.5.0/24"
  }
}

variable "tags" {
  type = map(string)
  default = {
    project = "landing-zone-students"
    managed = "terraform"
  }
}
