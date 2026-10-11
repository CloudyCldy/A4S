output "bastion_name" { value = azurerm_bastion_host.this.name }
output "bastion_public_ip" { value = azurerm_public_ip.bastion.ip_address }
