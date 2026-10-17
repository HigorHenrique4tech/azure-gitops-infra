resource "azurerm_container_registry" "this" {
  # Exceções conscientes ao checkov. O SKU Basic e o escopo do laboratório explicam todas:
  #checkov:skip=CKV_AZURE_163:A varredura de vulnerabilidades é feita no CI com Trivy, antes do push. O Defender for Containers é pago
  #checkov:skip=CKV_AZURE_164:Content trust exige Premium. As imagens são assinadas com Cosign e verificadas pelo Kyverno no cluster
  #checkov:skip=CKV_AZURE_166:Quarentena de imagens é recurso Premium. O scan do Trivy no CI cumpre o papel
  #checkov:skip=CKV_AZURE_167:Política de retenção de manifests sem tag exige Premium
  #checkov:skip=CKV_AZURE_233:Zona redundante exige Premium e não se justifica no laboratório
  #checkov:skip=CKV_AZURE_165:Georeplicação exige Premium. Há uma única região
  #checkov:skip=CKV_AZURE_237:Data endpoints dedicados exigem Premium
  #checkov:skip=CKV_AZURE_139:O GitHub Actions e o AKS precisam alcançar o registry pela internet. Private endpoint exige Premium

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  tags                = var.tags

  # O usuário admin é uma senha compartilhada do registry. Fica desligado e NÃO é uma
  # variável de propósito: ninguém deveria poder ligar por engano. Quem puxa ou envia imagem
  # usa identidade do Entra ID com a role AcrPull ou AcrPush, e o acesso fica auditável.
  admin_enabled = false

  public_network_access_enabled = var.public_network_access_enabled
}
