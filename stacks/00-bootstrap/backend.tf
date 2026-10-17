# Backend remoto: o state deixa de ficar no seu disco e passa a viver no Azure.
#
# Este bloco só foi adicionado DEPOIS do primeiro apply: a Storage Account precisava existir
# antes de poder guardar o state (o problema do ovo e da galinha). Depois disso, o state local foi
# migrado com `terraform init -migrate-state`.
#
# Backend não aceita variáveis, por isso os nomes ficam fixos aqui. Num fork com outra
# subscription, o nome da Storage Account muda (o sufixo depende da subscription); use então
# `terraform init -backend-config="storage_account_name=<nome>"`.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-gitops-tfstate"
    storage_account_name = "stgitopstfstate1f4e4e"
    container_name       = "tfstate"
    key                  = "00-bootstrap.tfstate"

    # Autentica no blob com o seu login do Entra ID (RBAC), não com chave de conta.
    use_azuread_auth = true
  }
}
