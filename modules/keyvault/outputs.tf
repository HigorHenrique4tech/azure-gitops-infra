output "id" {
  description = "ID do Key Vault (usado para atribuir roles de acesso aos segredos)."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Nome do Key Vault."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "Endereço do cofre, por exemplo https://meucofre.vault.azure.net/."
  value       = azurerm_key_vault.this.vault_uri
}
