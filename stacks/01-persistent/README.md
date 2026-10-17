# Stack 01-persistent

Camada **persistente** da plataforma: os recursos que precisam sobreviver quando o cluster AKS é destruído ao fim do dia. Aqui ficam as imagens, os segredos e os logs.

A camada **efêmera** (rede, AKS e bootstrap do ArgoCD) vive nas stacks seguintes e pode ser destruída e recriada à vontade. Esta não.

## O que é criado

O Resource Group `rg-gitops-persistent` **não** é criado aqui: ele nasce na stack `00-github-oidc`, que vem antes. Esta stack apenas o lê (`data`), porque a identidade do pipeline só tem permissão dentro dele, não para criar Resource Groups na subscription.

| Recurso | Nome | Para quê |
| --- | --- | --- |
| Container Registry (ACR) | `acrgitops<sufixo>` | Guarda as imagens de container da aplicação |
| Key Vault | `kv-gitops-<sufixo>` | Guarda os segredos da plataforma, com acesso por RBAC |
| Log Analytics Workspace | `law-gitops-persistent` | Centraliza logs e métricas, com retenção de 30 dias e limite diário de 0,5 GB |

O ACR e o Key Vault vêm dos módulos `modules/acr` e `modules/keyvault`. O `<sufixo>` são 6 caracteres derivados da subscription (a mesma fórmula do bootstrap), para os nomes serem únicos no Azure inteiro sem usar `random`.

## Outputs

| Output | Uso |
| --- | --- |
| `resource_group_name` | Resource Group da camada persistente |
| `acr_id`, `acr_name`, `acr_login_server` | Roles AcrPull e AcrPush, e o prefixo das imagens |
| `keyvault_id`, `keyvault_name`, `keyvault_uri` | Roles de acesso aos segredos e configuração do External Secrets |
| `log_analytics_id` | Destino dos diagnósticos do AKS |

## Decisões

- **Por que persistente?** Destruir o ACR apagaria as imagens, e destruir o Key Vault apagaria os segredos. O custo de manter esses recursos é de centavos, enquanto o do cluster é de horas de VM.
- **Sem usuário admin no ACR.** O acesso é por identidade do Entra ID, com as roles `AcrPush` (CI) e `AcrPull` (AKS).
- **Purge protection no Key Vault.** Depois de ligada, não desliga, e o nome do cofre fica reservado durante a retenção. Por isso esta stack não deve ser destruída e recriada por rotina.
- **Limite diário no Log Analytics** (`daily_quota_gb`). Passou do limite, o workspace para de ingerir até o dia seguinte. Perde-se log, mas a conta não dispara por causa de um componente que gera logs demais.
- **Tag `project = gitops-lab` em tudo.** É por ela que o budget do Azure conta o custo do laboratório.

## Como usar

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
cd stacks/01-persistent
terraform init
terraform plan
```

A ordem importa: aplique antes a stack `00-github-oidc`, senão o Resource Group não existe.

O `apply` desta stack é feito pelo pipeline (workflow `apply.yml`), com aprovação manual. O state fica em `01-persistent.tfstate`, no container criado pela stack `00-bootstrap`.
