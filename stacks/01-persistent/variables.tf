variable "location" {
  description = "Região do Azure onde a camada persistente é criada."
  type        = string
  default     = "eastus2"
}

variable "owner" {
  description = "Valor da tag owner, para saber quem é o dono dos recursos."
  type        = string
  default     = "higor"
}
