data "azurerm_client_config" "current" {}

locals {
  tags = {
    project    = "gitops-lab"
    env        = "shared"
    owner      = var.owner
    managed_by = "terraform"
  }

  # Mesma fórmula do bootstrap: um sufixo estável derivado da subscription, para nomes que
  # precisam ser únicos no Azure inteiro (ACR e Key Vault).
  suffix = substr(md5(data.azurerm_client_config.current.subscription_id), 0, 6)
}

# O Resource Group é criado pela stack 00-github-oidc (quem tem permissão de criar RG na subscription).
# Esta stack só o lê: a identidade do pipeline tem permissão apenas DENTRO dele.
data "azurerm_resource_group" "rg" {
  name = "rg-gitops-persistent"
}

module "acr" {
  source = "../../modules/acr"

  name                = "acrgitops${local.suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  name                = "kv-gitops-${local.suffix}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "law-gitops-persistent"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags

  # Limite diário de ingestão. Passou de 0,5 GB no dia, o workspace para de receber logs até o
  # dia seguinte. Perde-se log, mas a conta não explode por causa de um componente "tagarela".
  daily_quota_gb = 0.5
}
