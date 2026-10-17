# Testes do módulo network. Rodam com `terraform test` dentro da pasta do módulo.
# O mock_provider simula o Azure: nada é criado de verdade e o teste não custa nada.
mock_provider "azurerm" {}

variables {
  name                = "vnet-teste"
  resource_group_name = "rg-teste"
  location            = "eastus2"
  address_space       = ["10.10.0.0/16"]
  subnets = {
    aks-nodes = {
      address_prefixes = ["10.10.0.0/22"]
      nsg_rules = {
        allow-https = {
          priority               = 100
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          destination_port_range = "443"
        }
      }
    }
    apps = {
      address_prefixes = ["10.10.4.0/24"]
      create_nsg       = false
    }
  }
}

run "cria_duas_subnets_e_apenas_um_nsg" {
  command = plan

  assert {
    condition     = length(azurerm_subnet.this) == 2
    error_message = "Esperava 2 subnets."
  }

  assert {
    condition     = length(azurerm_network_security_group.this) == 1 && contains(keys(azurerm_network_security_group.this), "aks-nodes")
    error_message = "Só a subnet aks-nodes pediu NSG."
  }

  assert {
    condition     = azurerm_network_security_group.this["aks-nodes"].name == "nsg-aks-nodes"
    error_message = "O NSG deve se chamar nsg-<subnet>."
  }
}

run "rejeita_subnet_fora_do_address_space" {
  command = plan

  variables {
    subnets = {
      fora = { address_prefixes = ["192.168.0.0/24"] }
    }
  }

  expect_failures = [var.subnets]
}

run "rejeita_cidr_invalido_na_vnet" {
  command = plan

  variables {
    address_space = ["10.10.0.0/99"]
  }

  expect_failures = [var.address_space]
}

run "rejeita_prioridade_de_nsg_fora_da_faixa" {
  command = plan

  variables {
    subnets = {
      aks-nodes = {
        address_prefixes = ["10.10.0.0/22"]
        nsg_rules = {
          ruim = {
            priority               = 50
            direction              = "Inbound"
            access                 = "Allow"
            protocol               = "Tcp"
            destination_port_range = "443"
          }
        }
      }
    }
  }

  expect_failures = [var.subnets]
}
