
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/${var.network_state_path}"
  }
}

data "terraform_remote_state" "data" {
  backend = "local"
  config = {
    path = "${path.module}/${var.data_state_path}"
  }
}

locals {
  net  = data.terraform_remote_state.network.outputs
  data = data.terraform_remote_state.data.outputs
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

############################################################
# App Service (Linux, B1) con VNet Integration en snet-app
############################################################
resource "azurerm_service_plan" "app" {
  name                = "asp-${var.prefix}-app"
  location            = local.net.location
  resource_group_name = local.net.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.prefix}-${random_string.suffix.result}"
  location            = local.net.location
  resource_group_name = local.net.resource_group_name
  service_plan_id     = azurerm_service_plan.app.id
  https_only          = true

  # VNet Integration (snet-app delegada a Microsoft.Web/serverFarms)
  virtual_network_subnet_id = local.net.subnet_ids.app

  identity {
    type = "SystemAssigned" # MI de la aplicación
  }

  site_config {
    always_on              = true
    minimum_tls_version    = "1.2"
    ftps_state             = "Disabled"
    vnet_route_all_enabled = true

    application_stack {
      node_version = var.node_version
    }
  }

  app_settings = {
    PGHOST                      = local.data.postgres_fqdn
    PGPORT                      = "5432"
    PGDATABASE                  = local.data.postgres_database
    PGSSLMODE                   = "require"
    PGUSER                      = "app-${var.prefix}-${random_string.suffix.result}" # rol de BD = nombre de la MI
    AZURE_STORAGE_BLOB_ENDPOINT = local.data.blob_endpoint
    AZURE_STORAGE_CONTAINER     = local.data.blob_container
  }

  tags = var.tags
}

############################################################
# VM Linux B2ats_v2 (worker) en snet-vm, sin IP pública
############################################################
resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-worker"
  location            = local.net.location
  resource_group_name = local.net.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.net.subnet_ids.vm
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "worker" {
  name                = "vm-${var.prefix}-worker"
  location            = local.net.location
  resource_group_name = local.net.resource_group_name
  size                = var.vm_size
  admin_username      = var.vm_admin_username

  network_interface_ids = [azurerm_network_interface.vm.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.ssh_public_key
  }

  identity {
    type = "SystemAssigned" # MI de la VM
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server" # Gen2, requerido por B2ats_v2
    version   = "latest"
  }

  tags = var.tags
}

############################################################
# RBAC: ambas MI -> Storage Blob Data Contributor
############################################################
resource "azurerm_role_assignment" "app_blob" {
  scope                = local.data.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "vm_blob" {
  scope                = local.data.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.worker.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
