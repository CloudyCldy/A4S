data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/${var.network_state_path}"
  }
}

locals {
  net = data.terraform_remote_state.network.outputs
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  location            = local.net.location
  resource_group_name = local.net.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = "bas-${var.prefix}"
  location            = local.net.location
  resource_group_name = local.net.resource_group_name
  sku                 = var.bastion_sku
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = local.net.subnet_ids.bastion
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
