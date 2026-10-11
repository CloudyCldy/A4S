output "postgres_server_name" { value = azurerm_postgresql_flexible_server.this.name }
output "postgres_fqdn" { value = azurerm_postgresql_flexible_server.this.fqdn }
output "postgres_database" { value = azurerm_postgresql_flexible_server_database.app.name }
output "storage_account_id" { value = azurerm_storage_account.this.id }
output "storage_account_name" { value = azurerm_storage_account.this.name }
output "blob_endpoint" { value = azurerm_storage_account.this.primary_blob_endpoint }
output "blob_container" { value = azurerm_storage_container.uploads.name }

output "postgres_admin_password" {
  value     = random_password.pg_admin.result
  sensitive = true
}
