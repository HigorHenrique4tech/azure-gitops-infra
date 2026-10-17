# ADR 0001: State remoto do Terraform em Storage Account com Entra ID

- Status: aceita
- Data: 2026-10-17

## Contexto

O Terraform guarda em um arquivo (state) o mapa entre o código e os recursos reais. Se esse arquivo ficar só na máquina de quem roda, o pipeline de CI não enxerga a infraestrutura, duas pessoas podem aplicar ao mesmo tempo e perder o arquivo significa perder o controle dos recursos.

## Decisão

Guardar o state em um container de blob em uma Storage Account no Azure, com:

- autenticação só por Entra ID e RBAC, sem chave de conta;
- versionamento e retenção de 30 dias;
- um arquivo de state por stack, no mesmo container;
- lock automático pelo backend `azurerm` (lease do blob).

## Alternativas consideradas

- **State local:** simples, mas impede o CI e não protege contra perda do arquivo.
- **Terraform Cloud ou HCP:** resolve o problema, mas é outro serviço fora do Azure e fora do foco do laboratório.
- **Chave de conta ou SAS:** mais fácil de configurar, porém é um segredo de longa duração, o oposto do objetivo do projeto.

## Consequências

- O primeiro apply é feito com state local e migrado depois (ovo e galinha).
- Quem roda o Terraform precisa da role de dados *Storage Blob Data Contributor*, mesmo sendo Owner.
- O acesso de rede permanece público, porque os runners do GitHub não têm IP fixo. A mitigação é não existir chave: só identidades autorizadas conseguem ler o state.
- Private endpoint e chave gerenciada pelo cliente ficaram fora do escopo por custo e complexidade.
