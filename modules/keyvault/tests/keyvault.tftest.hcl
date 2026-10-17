mock_provider "azurerm" {}

variables {
  name                = "kv-gitops-teste"
  resource_group_name = "rg-teste"
  location            = "eastus2"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
}

run "cria_cofre_com_rbac_e_purge_protection" {
  command = plan

  assert {
    condition     = azurerm_key_vault.this.rbac_authorization_enabled == true
    error_message = "O cofre deve usar RBAC, não access policies."
  }

  assert {
    condition     = azurerm_key_vault.this.purge_protection_enabled == true
    error_message = "Purge protection deve vir ligada por padrão."
  }

  assert {
    condition     = azurerm_key_vault.this.soft_delete_retention_days == 7
    error_message = "A retenção padrão deve ser 7 dias."
  }
}

run "rejeita_nome_curto" {
  command = plan

  variables {
    name = "kv"
  }

  expect_failures = [var.name]
}

run "rejeita_nome_comecando_com_numero" {
  command = plan

  variables {
    name = "1kv-gitops"
  }

  expect_failures = [var.name]
}

run "rejeita_tenant_id_invalido" {
  command = plan

  variables {
    tenant_id = "nao-e-um-guid"
  }

  expect_failures = [var.tenant_id]
}

run "rejeita_retencao_fora_da_faixa" {
  command = plan

  variables {
    soft_delete_retention_days = 3
  }

  expect_failures = [var.soft_delete_retention_days]
}
