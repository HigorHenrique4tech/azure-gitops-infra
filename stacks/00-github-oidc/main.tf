data "azurerm_client_config" "current" {}

locals {
  tags = {
    project    = "gitops-lab"
    env        = "shared"
    owner      = var.owner
    managed_by = "terraform"
  }

  # Mesma fórmula do bootstrap: é assim que achamos a Storage Account do state.
  suffix = substr(md5(data.azurerm_client_config.current.subscription_id), 0, 6)

  # Resource Groups do projeto, criados aqui por quem é Owner. A identidade de apply só tem
  # permissão DENTRO deles: criar um Resource Group é uma ação da subscription, que ela não tem.
  resource_groups = {
    identity   = "rg-gitops-identity"
    persistent = "rg-gitops-persistent"
    aks        = "rg-gitops-aks"
  }

  # Prefixo do subject no formato IMUTÁVEL do GitHub: nome E ID do dono e do repositório.
  # Repositórios criados depois de 15/07/2026 já usam esse formato. A vantagem é de segurança:
  # se o repositório for apagado e outra pessoa recriar o mesmo nome, o ID muda e o token
  # dela deixa de casar com esta credencial. Só o nome não protegeria contra isso.
  subject_prefix = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}"

  # Duas identidades, com credenciais federadas diferentes:
  # - plan: aceita tokens de qualquer pull request do repositório (só planeja);
  # - apply: só aceita tokens de jobs que usam o Environment, que exige aprovação manual.
  # O subject precisa bater EXATAMENTE com o que o GitHub declara no token.
  identities = {
    plan = {
      name    = "id-gitops-gh-plan"
      subject = "${local.subject_prefix}:pull_request"
    }
    apply = {
      name    = "id-gitops-gh-apply"
      subject = "${local.subject_prefix}:environment:${var.github_environment}"
    }
  }

  # Quem pode fazer o quê, e onde. Cada item vira um role assignment.
  role_assignments = {
    plan-reader-persistent = {
      identity = "plan"
      role     = "Reader"
      scope    = azurerm_resource_group.this["persistent"].id
    }
    plan-reader-aks = {
      identity = "plan"
      role     = "Reader"
      scope    = azurerm_resource_group.this["aks"].id
    }
    plan-state = {
      identity = "plan"
      role     = "Storage Blob Data Contributor"
      scope    = data.azurerm_storage_account.state.id
    }
    apply-contributor-persistent = {
      identity = "apply"
      role     = "Contributor"
      scope    = azurerm_resource_group.this["persistent"].id
    }
    apply-contributor-aks = {
      identity = "apply"
      role     = "Contributor"
      scope    = azurerm_resource_group.this["aks"].id
    }
    apply-rbac-persistent = {
      identity = "apply"
      role     = "Role Based Access Control Administrator"
      scope    = azurerm_resource_group.this["persistent"].id
    }
    apply-rbac-aks = {
      identity = "apply"
      role     = "Role Based Access Control Administrator"
      scope    = azurerm_resource_group.this["aks"].id
    }
    apply-state = {
      identity = "apply"
      role     = "Storage Blob Data Contributor"
      scope    = data.azurerm_storage_account.state.id
    }
  }
}

# A Storage Account do state foi criada pela stack 00-bootstrap. Aqui só a lemos para obter o ID.
data "azurerm_storage_account" "state" {
  name                = "stgitopstfstate${local.suffix}"
  resource_group_name = "rg-gitops-tfstate"
}

resource "azurerm_resource_group" "this" {
  for_each = local.resource_groups

  name     = each.value
  location = var.location
  tags     = local.tags
}

# User Assigned Managed Identity: uma identidade do Azure sem senha, que existe por conta própria
# e à qual damos permissões. É o "usuário" que o pipeline vai assumir.
resource "azurerm_user_assigned_identity" "this" {
  for_each = local.identities

  name                = each.value.name
  resource_group_name = azurerm_resource_group.this["identity"].name
  location            = azurerm_resource_group.this["identity"].location
  tags                = local.tags
}

# A regra de confiança: "aceito tokens emitidos pelo GitHub Actions que tenham EXATAMENTE este subject".
resource "azurerm_federated_identity_credential" "this" {
  for_each = local.identities

  name                      = "github-${each.key}"
  user_assigned_identity_id = azurerm_user_assigned_identity.this[each.key].id
  issuer                    = "https://token.actions.githubusercontent.com"
  audience                  = ["api://AzureADTokenExchange"]
  subject                   = each.value.subject
}

resource "azurerm_role_assignment" "this" {
  for_each = local.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = azurerm_user_assigned_identity.this[each.value.identity].principal_id

  # A identidade acabou de ser criada e o Entra ID demora um pouco para "enxergá-la".
  # Sem estas duas linhas o apply falha de forma intermitente.
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
