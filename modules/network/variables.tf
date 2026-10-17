variable "name" {
  description = "Nome da Virtual Network."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 64
    error_message = "O nome da VNet deve ter entre 2 e 64 caracteres."
  }
}

variable "resource_group_name" {
  description = "Resource Group onde a VNet e os demais recursos de rede serão criados."
  type        = string
}

variable "location" {
  description = "Região do Azure, por exemplo eastus2."
  type        = string
}

variable "address_space" {
  description = "Faixas de IP (CIDR) da VNet, por exemplo [\"10.10.0.0/16\"]."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for c in var.address_space : can(cidrhost(c, 0))])
    error_message = "address_space precisa ter ao menos uma faixa e todas devem ser CIDRs válidos (ex.: 10.10.0.0/16)."
  }
}

variable "subnets" {
  description = <<-EOT
    Subnets da VNet, em um mapa onde a chave é o nome da subnet.
    - address_prefixes: faixas CIDR da subnet (precisam estar dentro do address_space)
    - create_nsg: cria e associa um Network Security Group à subnet (padrão: true)
    - nsg_rules: regras do NSG, em um mapa onde a chave é o nome da regra
  EOT
  type = map(object({
    address_prefixes = list(string)
    create_nsg       = optional(bool, true)
    nsg_rules = optional(map(object({
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_range     = string
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    })), {})
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "Defina ao menos uma subnet."
  }

  validation {
    condition = alltrue(flatten([
      for s in var.subnets : [for p in s.address_prefixes : can(cidrhost(p, 0))]
    ]))
    error_message = "Todos os address_prefixes das subnets devem ser CIDRs válidos."
  }

  # Confere se cada subnet cabe dentro de alguma faixa da VNet. O Terraform não tem uma função
  # "cidr contém", então a conta é: a subnet precisa ter máscara igual ou maior que a da faixa e,
  # ao aplicar a máscara da faixa sobre o endereço da subnet, o resultado é o endereço da própria
  # faixa. Ex.: 10.10.4.0/24 com máscara /16 vira 10.10.0.0, que é o início de 10.10.0.0/16.
  # try() evita um erro feio quando o CIDR é inválido: aí quem avisa é a validação anterior.
  validation {
    condition = alltrue(flatten([
      for s in var.subnets : [
        for p in s.address_prefixes : try(anytrue([
          for a in var.address_space :
          tonumber(split("/", p)[1]) >= tonumber(split("/", a)[1]) &&
          cidrhost("${cidrhost(p, 0)}/${split("/", a)[1]}", 0) == cidrhost(a, 0)
        ]), false)
      ]
    ]))
    error_message = "Toda subnet precisa estar dentro do address_space da VNet."
  }

  validation {
    condition = alltrue(flatten([
      for s in var.subnets : [
        for r in s.nsg_rules : r.priority >= 100 && r.priority <= 4096
      ]
    ]))
    error_message = "A prioridade das regras de NSG deve estar entre 100 e 4096."
  }

  validation {
    condition = alltrue(flatten([
      for s in var.subnets : [
        for r in s.nsg_rules : contains(["Inbound", "Outbound"], r.direction) && contains(["Allow", "Deny"], r.access)
      ]
    ]))
    error_message = "direction deve ser Inbound ou Outbound, e access deve ser Allow ou Deny."
  }
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos do módulo."
  type        = map(string)
  default     = {}
}
