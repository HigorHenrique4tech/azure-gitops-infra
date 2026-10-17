mock_provider "azurerm" {}

variables {
  name                = "acrgitopsteste"
  resource_group_name = "rg-teste"
  location            = "eastus2"
}

run "cria_registry_basic_sem_usuario_admin" {
  command = plan

  assert {
    condition     = azurerm_container_registry.this.sku == "Basic"
    error_message = "O SKU padrão deve ser Basic."
  }

  assert {
    condition     = azurerm_container_registry.this.admin_enabled == false
    error_message = "O usuário admin do ACR nunca deve ficar ligado."
  }
}

run "rejeita_nome_com_hifen" {
  command = plan

  variables {
    name = "acr-com-hifen"
  }

  expect_failures = [var.name]
}

run "rejeita_nome_curto" {
  command = plan

  variables {
    name = "acr"
  }

  expect_failures = [var.name]
}

run "rejeita_sku_inexistente" {
  command = plan

  variables {
    sku = "Premiun"
  }

  expect_failures = [var.sku]
}
