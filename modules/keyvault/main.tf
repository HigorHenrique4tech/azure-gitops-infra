resource "azurerm_key_vault" "this" {
  # Exceções conscientes ao checkov. O acesso é só por Entra ID e RBAC, nunca anônimo:
  #checkov:skip=CKV_AZURE_189:O External Secrets Operator e o pipeline precisam alcançar o cofre pela internet. Private endpoint está fora do escopo
  #checkov:skip=CKV_AZURE_109:Um firewall com default Deny bloquearia os pods do AKS, que não têm IP fixo. O controle é por RBAC
  #checkov:skip=CKV2_AZURE_32:Private endpoint custa e exigiria rede privada para quem opera. Fora do escopo do laboratório

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name
  tags                = var.tags

  # RBAC no lugar das antigas "access policies": quem pode ler ou gravar segredo é definido por
  # role assignment (Key Vault Secrets User, Key Vault Secrets Officer...), no mesmo modelo de
  # permissões do resto do Azure. É assim que o External Secrets Operator vai acessar o cofre.
  # No provider 5.x este argumento é obrigatório.
  rbac_authorization_enabled = true

  # Apagou um segredo sem querer? Dá para recuperar durante a retenção. Com purge protection,
  # nem um administrador consegue apagar de vez antes do prazo.
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled

  public_network_access_enabled = var.public_network_access_enabled
}
