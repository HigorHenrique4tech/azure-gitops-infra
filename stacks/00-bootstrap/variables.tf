variable "location" {
  description = "Região do Azure onde o state é guardado."
  type        = string
  default     = "eastus2"
}

variable "owner" {
  description = "Valor da tag owner, para saber quem é o dono dos recursos."
  type        = string
  default     = "higor"
}
