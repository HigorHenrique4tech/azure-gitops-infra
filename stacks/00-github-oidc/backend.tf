# Backend remoto: o state desta stack vive no mesmo container criado pela stack 00-bootstrap,
# em um arquivo próprio (key).
#
# Backend não aceita variáveis, por isso os nomes ficam fixos aqui. Num fork com outra
# subscription, o nome da Storage Account muda (o sufixo depende da subscription); use então
# `terraform init -backend-config="storage_account_name=<nome>"`.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-gitops-tfstate"
    storage_account_name = "stgitopstfstate1f4e4e"
    container_name       = "tfstate"
    key                  = "00-github-oidc.tfstate"

    # Autentica no blob com o seu login do Entra ID (RBAC), não com chave de conta.
    use_azuread_auth = true
  }
}
