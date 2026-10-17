variable "name" {
  description = "Nome do Key Vault. Único no Azure inteiro: 3 a 24 caracteres, letras, números e hífen, começando por letra."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name)) && !can(regex("--", var.name))
    error_message = "O nome deve ter de 3 a 24 caracteres, começar por letra, terminar em letra ou número e não ter hífens seguidos."
  }
}

variable "resource_group_name" {
  description = "Resource Group onde o Key Vault será criado."
  type        = string
}

variable "location" {
  description = "Região do Azure, por exemplo eastus2."
  type        = string
}

variable "tenant_id" {
  description = "ID do tenant do Entra ID que autentica os acessos ao cofre."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "tenant_id deve ser um GUID válido."
  }
}

variable "sku_name" {
  description = "SKU do cofre. standard guarda segredos, chaves e certificados em software; premium usa HSM."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name deve ser standard ou premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Dias em que um item apagado pode ser recuperado. Só pode ser definido uma vez, na criação do cofre."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days deve estar entre 7 e 90."
  }
}

variable "purge_protection_enabled" {
  description = "Impede apagar definitivamente o cofre ou seus itens durante o período de retenção. Depois de ligada, não dá para desligar."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Permite acesso pela internet. Precisa ser true enquanto não houver private endpoint."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags aplicadas ao cofre."
  type        = map(string)
  default     = {}
}
