# A subscription NÃO é escrita aqui: este repositório é público.
# O provider lê a variável de ambiente ARM_SUBSCRIPTION_ID. Localmente:
#   export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
#
# Desde a versão 5.0 o provider não registra mais os Resource Providers do Azure
# sozinho. Os usados no projeto já estão registrados na subscription.
provider "azurerm" {
  features {}
}
