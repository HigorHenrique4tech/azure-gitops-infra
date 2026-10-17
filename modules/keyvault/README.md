# Módulo keyvault

Cria um Azure Key Vault: o cofre onde ficam os segredos da plataforma.

## Decisões de segurança

- **RBAC em vez de access policies.** Quem lê ou grava segredo é definido por role assignment, como no resto do Azure. É por isso que o módulo não concede acesso a ninguém: a stack que usa o módulo atribui as roles (por exemplo, `Key Vault Secrets User` para o External Secrets Operator).
- **Purge protection ligada por padrão.** Nem um administrador consegue apagar o cofre de vez durante o período de retenção. Depois de ligada, não pode ser desligada, e o nome do cofre fica reservado até o fim da retenção.
- **Soft delete com 7 dias**, o mínimo. Esse valor só pode ser definido na criação.

## Exemplo

```hcl
module "keyvault" {
  source = "../../modules/keyvault"

  name                = "kv-gitops-lab"
  resource_group_name = azurerm_resource_group.this.name
  location            = "eastus2"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  tags = local.tags
}
```

## Testes

```bash
cd modules/keyvault
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
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Região do Azure, por exemplo eastus2. | `string` | n/a | yes |
| name | Nome do Key Vault. Único no Azure inteiro: 3 a 24 caracteres, letras, números e hífen, começando por letra. | `string` | n/a | yes |
| resource\_group\_name | Resource Group onde o Key Vault será criado. | `string` | n/a | yes |
| tenant\_id | ID do tenant do Entra ID que autentica os acessos ao cofre. | `string` | n/a | yes |
| public\_network\_access\_enabled | Permite acesso pela internet. Precisa ser true enquanto não houver private endpoint. | `bool` | `true` | no |
| purge\_protection\_enabled | Impede apagar definitivamente o cofre ou seus itens durante o período de retenção. Depois de ligada, não dá para desligar. | `bool` | `true` | no |
| sku\_name | SKU do cofre. standard guarda segredos, chaves e certificados em software; premium usa HSM. | `string` | `"standard"` | no |
| soft\_delete\_retention\_days | Dias em que um item apagado pode ser recuperado. Só pode ser definido uma vez, na criação do cofre. | `number` | `7` | no |
| tags | Tags aplicadas ao cofre. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| id | ID do Key Vault (usado para atribuir roles de acesso aos segredos). |
| name | Nome do Key Vault. |
| vault\_uri | Endereço do cofre, por exemplo https://meucofre.vault.azure.net/. |
<!-- END_TF_DOCS -->
