# azure-gitops-infra

Infraestrutura como código da plataforma GitOps no Azure: Terraform para state remoto, rede, ACR, Key Vault, AKS e bootstrap do ArgoCD.

Parte do projeto [projeto-gitops](https://github.com/HigorHenrique4tech/projeto-gitops), junto com `azure-gitops-app` e `azure-gitops-config`.

> Projeto de laboratório e portfólio. Em construção.

## Desenvolvimento

```bash
pre-commit install   # instala os hooks de pre-commit e commit-msg
pre-commit run --all-files
```

Commits seguem [Conventional Commits](https://www.conventionalcommits.org/) e são assinados com chave SSH.
