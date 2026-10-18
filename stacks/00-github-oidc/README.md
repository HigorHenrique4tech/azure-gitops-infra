# Stack 00-github-oidc

Cria a identidade que permite ao GitHub Actions falar com o Azure **sem nenhuma senha**, usando OIDC (federação de identidade), e os Resource Groups onde o pipeline pode trabalhar.

É o segundo bootstrap do projeto: o pipeline não pode criar a identidade de que ele mesmo precisa para rodar. Por isso esta stack é aplicada **localmente**, uma vez, por quem é Owner da subscription.

## Como funciona o OIDC

1. Cada job do GitHub Actions recebe um token assinado pelo GitHub, que declara de onde vem (repositório, ambiente).
2. No Azure, uma **federated credential** diz: "aceito tokens do GitHub com exatamente este `subject`".
3. O job troca o token do GitHub por um token do Azure, válido por poucos minutos.

Não existe segredo para vazar, vencer ou girar. A segurança está no `subject`, que precisa bater exatamente.

## O que é criado

| Recurso | Nome | Para quê |
| --- | --- | --- |
| Resource Group | `rg-gitops-identity` | Guarda as identidades |
| Resource Group | `rg-gitops-persistent` | Camada persistente (ACR, Key Vault, Log Analytics) |
| Resource Group | `rg-gitops-aks` | Camada efêmera (rede, AKS) |
| Managed Identity | `id-gitops-gh-plan` | Usada nos pull requests, só lê |
| Managed Identity | `id-gitops-gh-apply` | Usada no apply, depois da aprovação manual |
| Federated credential | `github-plan` | Aceita o subject `repo:<dono>@<id>/<repo>@<id>:pull_request` |
| Federated credential | `github-apply` | Aceita o subject `repo:<dono>@<id>/<repo>@<id>:environment:<ambiente>` |

## Permissões

| Identidade | Role | Escopo |
| --- | --- | --- |
| plan | Reader | `rg-gitops-persistent` e `rg-gitops-aks` |
| plan | Storage Blob Data Contributor | Storage Account do state |
| apply | Contributor | `rg-gitops-persistent` e `rg-gitops-aks` |
| apply | Role Based Access Control Administrator | `rg-gitops-persistent` e `rg-gitops-aks` |
| apply | Storage Blob Data Contributor | Storage Account do state |

## Decisões

- **Duas identidades.** Um PR roda com uma identidade que não cria nem apaga nada. A identidade de apply só é emitida a jobs que usam o Environment do GitHub, que exige aprovação manual.
- **Escopo por Resource Group, não por subscription.** A subscription tem outros recursos reais. Com o escopo limitado, o pipeline não consegue tocá-los, nem por engano nem por um PR malicioso. É por isso que os Resource Groups são criados aqui: criar um RG é uma ação da subscription, que a identidade de apply não possui.
- **Contributor + RBAC Administrator.** O Contributor cria recursos, mas não pode criar role assignments. As stacks seguintes precisam deles (AcrPull para o AKS, acesso do External Secrets ao Key Vault).
- **O plan escreve no state.** O `plan` pega o lock do state, que é uma gravação no blob. Sem a role de dados, nem o plan roda.
- **Subject imutável (com IDs).** Repositórios criados depois de 15/07/2026 emitem o `sub` com o ID numérico do dono e do repositório (`repo:dono@123/repo@456:...`). A primeira versão desta stack usava só os nomes e o login falhou com `AADSTS700213: No matching federated identity record`; o log do `azure/login` mostra o subject real que o GitHub enviou, e foi assim que o erro foi achado. Os IDs vêm das variáveis `github_owner_id` e `github_repo_id`. O formato é mais seguro: se o repositório for apagado e alguém recriar o mesmo nome, o ID muda e o token dele não casa mais. O prefixo exato de um repositório se obtém com `gh api repos/<dono>/<repo>/actions/oidc/customization/sub --jq .sub_claim_prefix`.
- **`subject` por Environment no apply, não por branch.** Com `ref:refs/heads/main`, qualquer merge na `main` poderia aplicar sem aprovação. Com o Environment, o job só recebe o token depois que o revisor aprova.

## Como usar

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
cd stacks/00-github-oidc
terraform init
terraform plan
terraform apply
```

Aplicar antes da stack `01-persistent`, que usa o Resource Group criado aqui.

Os valores dos outputs (`tenant_id`, `plan_client_id`, `apply_client_id`) vão para as variáveis do repositório no GitHub. Não são segredos, mas não os escreva em arquivos versionados.
