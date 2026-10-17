config {
  # Também analisa os módulos chamados pelo código.
  call_module_type = "local"
}

# Regras da linguagem Terraform: variável sem tipo ou descrição, output sem descrição, etc.
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Regras específicas do Azure: tamanho de VM que não existe, SKU inválido, etc.
# Baixe os plugins uma vez com:  tflint --init
plugin "azurerm" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
