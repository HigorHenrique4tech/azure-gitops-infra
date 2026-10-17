terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Módulo reutilizável declara uma FAIXA de versões. Quem fixa a versão exata é a stack
      # que usa o módulo (via .terraform.lock.hcl), não o módulo.
      version = ">= 5.0, < 6.0"
    }
  }
}
