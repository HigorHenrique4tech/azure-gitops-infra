# Stack 00-bootstrap

Cria o lugar onde o Terraform guarda o state de todas as outras stacks: um Resource Group, uma Storage Account e um container de blob.

## O que é criado

| Recurso | Nome | Para quê |
| --- | --- | --- |
| Resource Group | `rg-gitops-tfstate` | Agrupa tudo que guarda state, separado do resto do laboratório |
| Storage Account | `stgitopstfstate<sufixo>` | Guarda os arquivos `.tfstate` |
| Container | `tfstate` | Pasta privada dentro da conta; um blob por stack |
| Role assignment | Storage Blob Data Contributor | Dá a quem roda o Terraform acesso aos dados do blob |

## Decisões de segurança

- **Sem chave de conta** (`shared_access_key_enabled = false`): todo acesso exige identidade do Entra ID e RBAC.
- **TLS 1.2 mínimo, sem blob público e sem acesso cross-tenant.**
- **Versionamento** do blob e **retenção de 30 dias** para blob e container apagados.
- **`prevent_destroy`** na Storage Account, contra `terraform destroy` acidental.
- **Lock do state** pelo próprio backend `azurerm`, via lease do blob: duas execuções simultâneas não corrompem o state.

As exceções ao checkov estão justificadas dentro do `main.tf`.

## Como usar

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
terraform init
terraform plan
```

## Por que esta stack foi criada em duas etapas

O state precisa de um lugar para morar, mas esse lugar é criado pelo próprio Terraform (ovo e galinha):

1. Primeiro apply **sem** `backend.tf`, com state local.
2. Depois de criada a Storage Account, adicionou-se o `backend.tf` e rodou-se `terraform init -migrate-state`.

Num fork com outra subscription, o sufixo do nome muda. Ajuste o `backend.tf` ou use `-backend-config`.
