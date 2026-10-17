terraform {
  # Versão mínima do Terraform. Sem teto, para o CI e a sua máquina poderem evoluir juntos.
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # "~> 5.10" aceita 5.10 até 5.x, mas nunca a 6.0 (que pode quebrar o código).
      version = "~> 5.10"
    }
  }
}
