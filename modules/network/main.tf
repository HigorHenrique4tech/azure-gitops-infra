locals {
  # Só as subnets que pediram NSG. O for filtra o mapa e mantém as mesmas chaves,
  # o que permite ligar cada NSG à sua subnet pela chave.
  subnets_with_nsg = { for name, s in var.subnets : name => s if s.create_nsg }
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

# for_each cria uma subnet por item do mapa. A chave do mapa vira o nome e também o endereço
# no state (azurerm_subnet.this["aks-nodes"]). Remover uma subnet do meio não afeta as outras,
# o que não vale para count, que identifica por posição.
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_network_security_group" "this" {
  for_each = local.subnets_with_nsg

  name                = "nsg-${each.key}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  # dynamic gera um bloco security_rule para cada regra declarada na variável.
  dynamic "security_rule" {
    for_each = each.value.nsg_rules

    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = local.subnets_with_nsg

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
