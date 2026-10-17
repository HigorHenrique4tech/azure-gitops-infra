# Módulo network

Cria uma Virtual Network (VNet) com subnets e, opcionalmente, um Network Security Group (NSG) por subnet.

Uma **VNet** é a rede privada no Azure onde os recursos conversam. Uma **subnet** é uma fatia dessa rede. Um **NSG** é o firewall da subnet: uma lista de regras que permite ou bloqueia tráfego.

## Exemplo

```hcl
module "network" {
  source = "../../modules/network"

  name                = "vnet-gitops-dev"
  resource_group_name = azurerm_resource_group.this.name
  location            = "eastus2"
  address_space       = ["10.10.0.0/16"]

  subnets = {
    aks-nodes = {
      address_prefixes = ["10.10.0.0/22"]
    }
    apps = {
      address_prefixes = ["10.10.4.0/24"]
      create_nsg       = false
    }
  }

  tags = local.tags
}
```

## Validações

O módulo recusa, antes de falar com o Azure: CIDR inválido, subnet fora do `address_space`, prioridade de regra fora de 100 a 4096 e `direction`/`access` inexistentes.

## Testes

```bash
cd modules/network
terraform init -backend=false
terraform test
```

Os testes usam um provider simulado (`mock_provider`): não criam nada no Azure e não têm custo.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.9.0 |
| azurerm | >= 5.0, < 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| azurerm | >= 5.0, < 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| address\_space | Faixas de IP (CIDR) da VNet, por exemplo ["10.10.0.0/16"]. | `list(string)` | n/a | yes |
| location | Região do Azure, por exemplo eastus2. | `string` | n/a | yes |
| name | Nome da Virtual Network. | `string` | n/a | yes |
| resource\_group\_name | Resource Group onde a VNet e os demais recursos de rede serão criados. | `string` | n/a | yes |
| subnets | Subnets da VNet, em um mapa onde a chave é o nome da subnet. - address\_prefixes: faixas CIDR da subnet (precisam estar dentro do address\_space) - create\_nsg: cria e associa um Network Security Group à subnet (padrão: true) - nsg\_rules: regras do NSG, em um mapa onde a chave é o nome da regra | ```map(object({ address_prefixes = list(string) create_nsg = optional(bool, true) nsg_rules = optional(map(object({ priority = number direction = string access = string protocol = string source_port_range = optional(string, "*") destination_port_range = string source_address_prefix = optional(string, "*") destination_address_prefix = optional(string, "*") })), {}) }))``` | n/a | yes |
| tags | Tags aplicadas a todos os recursos do módulo. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| nsg\_ids | IDs dos NSGs criados, em um mapa nome da subnet => ID do NSG. |
| subnet\_ids | IDs das subnets, em um mapa nome => ID. |
| vnet\_id | ID da Virtual Network. |
| vnet\_name | Nome da Virtual Network. |
<!-- END_TF_DOCS -->
