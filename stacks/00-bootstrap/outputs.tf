output "resource_group_name" {
  description = "Resource Group que guarda o state."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Nome da Storage Account do state (vai no bloco backend das outras stacks)."
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Container onde ficam os arquivos .tfstate."
  value       = azurerm_storage_container.tfstate.name
}
