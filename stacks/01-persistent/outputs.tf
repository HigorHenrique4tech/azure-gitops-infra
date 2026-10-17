output "resource_group_name" {
  description = "Resource Group da camada persistente."
  value       = azurerm_resource_group.rg.name
}

output "acr_id" {
  description = "ID do Container Registry (usado para atribuir as roles AcrPull e AcrPush)."
  value       = module.acr.id
}

output "acr_name" {
  description = "Nome do Container Registry."
  value       = module.acr.name
}

output "acr_login_server" {
  description = "Endereço do registry, prefixo das imagens (ex.: meuacr.azurecr.io)."
  value       = module.acr.login_server
}

output "keyvault_id" {
  description = "ID do Key Vault (usado para atribuir roles de acesso aos segredos)."
  value       = module.keyvault.id
}

output "keyvault_name" {
  description = "Nome do Key Vault."
  value       = module.keyvault.name
}

output "keyvault_uri" {
  description = "Endereço do cofre (ex.: https://meucofre.vault.azure.net/)."
  value       = module.keyvault.vault_uri
}

output "log_analytics_id" {
  description = "ID do workspace do Log Analytics."
  value       = azurerm_log_analytics_workspace.log_analytics.id
}
