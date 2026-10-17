variable "location" {
  description = "Região do Azure onde os Resource Groups e as identidades são criados."
  type        = string
  default     = "eastus2"
}

variable "owner" {
  description = "Valor da tag owner, para saber quem é o dono dos recursos."
  type        = string
  default     = "higor"
}

variable "github_owner" {
  description = "Usuário ou organização dona do repositório no GitHub. Compõe o subject da credencial federada."
  type        = string
  default     = "HigorHenrique4tech"
}

variable "github_repo" {
  description = "Repositório no GitHub cujos workflows podem usar as identidades."
  type        = string
  default     = "azure-gitops-infra"
}

variable "github_environment" {
  description = "Nome do GitHub Environment que exige aprovação e libera a identidade de apply."
  type        = string
  default     = "azure-dev"
}
