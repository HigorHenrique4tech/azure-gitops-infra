variable "name" {
  description = "Nome do Container Registry. Único no Azure inteiro: 5 a 50 caracteres, só letras e números."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "O nome do ACR deve ter de 5 a 50 caracteres, somente letras e números (sem hífen)."
  }
}

variable "resource_group_name" {
  description = "Resource Group onde o registry será criado."
  type        = string
}

variable "location" {
  description = "Região do Azure, por exemplo eastus2."
  type        = string
}

variable "sku" {
  description = "SKU do registry. Basic é o mais barato e suficiente para o laboratório."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "O SKU deve ser Basic, Standard ou Premium."
  }
}

variable "public_network_access_enabled" {
  description = "Permite acesso pela internet. Precisa ser true para o GitHub Actions e para o AKS sem private endpoint."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags aplicadas ao registry."
  type        = map(string)
  default     = {}
}
