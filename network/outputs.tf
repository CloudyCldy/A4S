output "resource_group_name" { value = azurerm_resource_group.this.name }
output "location" { value = azurerm_resource_group.this.location }
output "vnet_id" { value = azurerm_virtual_network.this.id }
output "vnet_name" { value = azurerm_virtual_network.this.name }

output "subnet_ids" {
  value = {
    app       = azurerm_subnet.app.id
    db        = azurerm_subnet.db.id
    vm        = azurerm_subnet.vm.id
    endpoints = azurerm_subnet.endpoints.id
    bastion   = azurerm_subnet.bastion.id
  }
}

output "subnet_cidrs" { value = var.subnet_cidrs }

output "private_dns_zone_ids" {
  value = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}
