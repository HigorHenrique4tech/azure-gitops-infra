# Backend remoto: o state desta stack vive no mesmo container criado pela stack 00-bootstrap,
# em um arquivo próprio (key). Cada stack tem o seu arquivo, então uma não enxerga nem
# corrompe o state da outra.
#
# Backend não aceita variáveis, por isso os nomes ficam fixos aqui. Num fork com outra
# subscription, o nome da Storage Account muda (o sufixo depende da subscription); use então
# `terraform init -backend-config="storage_account_name=<nome>"`.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-gitops-tfstate"
    storage_account_name = "stgitopstfstate1f4e4e"
    container_name       = "tfstate"
    key                  = "01-persistent.tfstate"

    # Autentica no blob com o seu login do Entra ID (RBAC), não com chave de conta.
    use_azuread_auth = true
  }
}
