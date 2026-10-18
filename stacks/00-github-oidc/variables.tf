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

variable "github_owner_id" {
  description = "ID numérico do dono do repositório no GitHub. Veja: gh api users/<dono> --jq .id"
  type        = string
  default     = "78054896"

  validation {
    condition     = can(regex("^[0-9]+$", var.github_owner_id))
    error_message = "O ID do dono deve conter apenas dígitos."
  }
}

variable "github_repo_id" {
  description = "ID numérico do repositório no GitHub. Veja: gh api repos/<dono>/<repo> --jq .id"
  type        = string
  default     = "1421551565"

  validation {
    condition     = can(regex("^[0-9]+$", var.github_repo_id))
    error_message = "O ID do repositório deve conter apenas dígitos."
  }
}

variable "github_environment" {
  description = "Nome do GitHub Environment que exige aprovação e libera a identidade de apply."
  type        = string
  default     = "azure-dev"
}
