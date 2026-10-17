# Módulo acr

Cria um Azure Container Registry (ACR): o lugar onde ficam as imagens de container da aplicação.

## Decisões de segurança

- **Usuário admin desligado e não configurável.** O admin é uma senha compartilhada do registry. O acesso é sempre por identidade do Entra ID com as roles `AcrPush` (CI) e `AcrPull` (AKS), que ficam auditáveis e não vazam como senha.
- **SKU Basic por padrão**, o mais barato. Recursos como georreplicação, quarentena e private endpoint exigem Premium e estão registrados como exceções justificadas no `main.tf`.

## Exemplo

```hcl
module "acr" {
  source = "../../modules/acr"

  name                = "acrgitopslab"
  resource_group_name = azurerm_resource_group.this.name
  location            = "eastus2"

  tags = local.tags
}
```

## Testes

```bash
cd modules/acr
terraform init -backend=false
terraform test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.9.0 |
| azurerm | >= 5.0, < 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| azurerm | >= 5.0, < 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Região do Azure, por exemplo eastus2. | `string` | n/a | yes |
| name | Nome do Container Registry. Único no Azure inteiro: 5 a 50 caracteres, só letras e números. | `string` | n/a | yes |
| resource\_group\_name | Resource Group onde o registry será criado. | `string` | n/a | yes |
| public\_network\_access\_enabled | Permite acesso pela internet. Precisa ser true para o GitHub Actions e para o AKS sem private endpoint. | `bool` | `true` | no |
| sku | SKU do registry. Basic é o mais barato e suficiente para o laboratório. | `string` | `"Basic"` | no |
| tags | Tags aplicadas ao registry. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| id | ID do Container Registry (usado para atribuir as roles AcrPull e AcrPush). |
| login\_server | Endereço do registry, por exemplo meuacr.azurecr.io. É o prefixo das imagens. |
| name | Nome do Container Registry. |
<!-- END_TF_DOCS -->
