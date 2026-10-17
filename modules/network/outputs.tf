output "vnet_id" {
  description = "ID da Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Nome da Virtual Network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "IDs das subnets, em um mapa nome => ID."
  value       = { for name, s in azurerm_subnet.this : name => s.id }
}

output "nsg_ids" {
  description = "IDs dos NSGs criados, em um mapa nome da subnet => ID do NSG."
  value       = { for name, n in azurerm_network_security_group.this : name => n.id }
}
