output "id" {
  description = "ID do Container Registry (usado para atribuir as roles AcrPull e AcrPush)."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Nome do Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Endereço do registry, por exemplo meuacr.azurecr.io. É o prefixo das imagens."
  value       = azurerm_container_registry.this.login_server
}
