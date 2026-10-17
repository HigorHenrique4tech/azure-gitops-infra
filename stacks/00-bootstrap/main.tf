# Quem está rodando o Terraform (usuário do `az login` ou, no CI, a identidade OIDC).
data "azurerm_client_config" "current" {}

locals {
  # A tag project=gitops-lab é a que o budget do Azure usa para contar o custo do laboratório.
  tags = {
    project    = "gitops-lab"
    env        = "shared"
    owner      = var.owner
    managed_by = "terraform"
  }

  # Nome de Storage Account é único no Azure inteiro. Um sufixo derivado da subscription
  # evita colisão e é estável: o mesmo código dá o mesmo nome toda vez, sem random.
  suffix = substr(md5(data.azurerm_client_config.current.subscription_id), 0, 6)
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-gitops-tfstate"
  location = var.location
  tags     = local.tags
}

# Guarda o state de todas as outras stacks.
resource "azurerm_storage_account" "tfstate" {
  # Exceções conscientes ao checkov. Cada uma é uma decisão, não um esquecimento:
  #checkov:skip=CKV_AZURE_59:Precisa de acesso de rede público para os runners do GitHub. O acesso é só por Entra ID, sem chave
  #checkov:skip=CKV2_AZURE_33:Private endpoint custa e exigiria runner dentro da rede. Fora do escopo do laboratório
  #checkov:skip=CKV_AZURE_206:LRS basta. O state é recriável e o versionamento cobre erro humano
  #checkov:skip=CKV2_AZURE_1:Chave gerenciada pelo cliente (CMK) está fora do escopo do laboratório
  #checkov:skip=CKV_AZURE_33:O serviço de filas (Queue) não é usado nesta conta
  #checkov:skip=CKV_AZURE_43:O nome é calculado com interpolação; o checkov não resolve e acusa falso positivo

  name                = "stgitopstfstate${local.suffix}"
  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location
  tags                = local.tags

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Segurança: só TLS 1.2, nada de blob público, e sem chave de conta.
  # Sem chave compartilhada, toda requisição precisa de identidade do Entra ID + RBAC.
  min_tls_version                  = "TLS1_2"
  https_traffic_only_enabled       = true
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = false
  default_to_oauth_authentication  = true
  cross_tenant_replication_enabled = false
  local_user_enabled               = false

  blob_properties {
    # Cada gravação do state vira uma versão. Estragou o state? Dá para voltar atrás.
    versioning_enabled = true

    # Blob e container apagados ficam recuperáveis por 30 dias.
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  # Proteção contra `terraform destroy` acidental: perder esta conta é perder o state de tudo.
  lifecycle {
    prevent_destroy = true
  }
}

# Container privado que guarda os arquivos .tfstate (um por stack).
# O argumento storage_account_id faz o Terraform criar o container pelo plano de gerenciamento
# (ARM), então não é preciso ter permissão de dados para criá-lo.
resource "azurerm_storage_container" "tfstate" {
  #checkov:skip=CKV2_AZURE_21:Log de leitura do blob exige um Log Analytics só para isso. Será avaliado junto da camada persistente

  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# Ser Owner da subscription NÃO dá acesso aos dados do blob. Aqui damos explicitamente
# a role de dados a quem roda o Terraform, para ele conseguir ler e gravar o state.
resource "azurerm_role_assignment" "state_data_access" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
