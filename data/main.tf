data "azurerm_client_config" "current" {}

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "${path.module}/${var.network_state_path}"
  }
}

locals {
  net = data.terraform_remote_state.network.outputs
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "random_password" "pg_admin" {
  length  = 24
  special = true
}

############################################################
# PostgreSQL Flexible Server - Burstable B1ms
############################################################
resource "azurerm_postgresql_flexible_server" "this" {
  name                = "psql-${var.prefix}-${random_string.suffix.result}"
  resource_group_name = local.net.resource_group_name
  location            = local.net.location
  version             = var.postgres_version

  sku_name   = var.postgres_sku
  storage_mb = var.postgres_storage_mb

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  # Acceso público deshabilitado: solo Private Link
  public_network_access_enabled = false

  administrator_login    = var.postgres_admin_login
  administrator_password = random_password.pg_admin.result

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "this" {
  server_name         = azurerm_postgresql_flexible_server.this.name
  resource_group_name = local.net.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = coalesce(var.entra_admin_object_id, data.azurerm_client_config.current.object_id)
  principal_name      = var.entra_admin_principal_name
  principal_type      = var.entra_admin_principal_type
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = var.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

############################################################
# Storage Account - Blob, Standard LRS
############################################################
resource "azurerm_storage_account" "this" {
  name                     = "st${var.prefix}${random_string.suffix.result}"
  resource_group_name      = local.net.resource_group_name
  location                 = local.net.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true

  tags = var.tags
}

# Se crea por ARM (storage_account_id) para no requerir acceso de plano de datos
resource "azurerm_storage_container" "uploads" {
  name                  = var.blob_container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

############################################################
# Private Endpoints + registros en Private DNS
############################################################
resource "azurerm_private_endpoint" "postgres" {
  name                = "pe-postgres"
  location            = local.net.location
  resource_group_name = local.net.resource_group_name
  subnet_id           = local.net.subnet_ids.db
  tags                = var.tags

  private_service_connection {
    name                           = "psc-postgres"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "ipconfig-postgres"
    private_ip_address = var.pe_postgres_ip
    subresource_name   = "postgresqlServer"
  }

  private_dns_zone_group {
    name                 = "pdzg-postgres"
    private_dns_zone_ids = [local.net.private_dns_zone_ids.postgres]
  }
}

resource "azurerm_private_endpoint" "blob" {
  name                = "pe-blob"
  location            = local.net.location
  resource_group_name = local.net.resource_group_name
  subnet_id           = local.net.subnet_ids.endpoints
  tags                = var.tags

  private_service_connection {
    name                           = "psc-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "ipconfig-blob"
    private_ip_address = var.pe_blob_ip
    subresource_name   = "blob"
  }

  private_dns_zone_group {
    name                 = "pdzg-blob"
    private_dns_zone_ids = [local.net.private_dns_zone_ids.blob]
  }
}
