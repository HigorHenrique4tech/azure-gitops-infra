output "tenant_id" {
  description = "ID do tenant do Entra ID. Vai para a variável AZURE_TENANT_ID do GitHub."
  value       = data.azurerm_client_config.current.tenant_id
}

output "plan_client_id" {
  description = "Client ID da identidade de plan (somente leitura). Vai para a variável do GitHub usada nos PRs."
  value       = azurerm_user_assigned_identity.this["plan"].client_id
}

output "apply_client_id" {
  description = "Client ID da identidade de apply. Vai para a variável do GitHub usada no job com aprovação."
  value       = azurerm_user_assigned_identity.this["apply"].client_id
}

output "resource_group_names" {
  description = "Resource Groups criados, em um mapa chave => nome."
  value       = { for k, rg in azurerm_resource_group.this : k => rg.name }
}
