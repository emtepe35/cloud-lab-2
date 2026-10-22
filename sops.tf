data "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

locals {
  sops_to_keyvault_mapping = {
    "devops-sp-username" = data.sops_file.secrets.data["devops_sp_username"]
    "devops-sp-password" = data.sops_file.secrets.data["devops_sp_password"]
  }
}

resource "azurerm_key_vault_secret" "devops" {
  for_each = local.sops_to_keyvault_mapping

  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id

  tags = merge(local.project_tags, {
    source    = "sops"
    encrypted = "true"
  })

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    azurerm_role_assignment.sops_crypto_user,
    azurerm_role_assignment.key_vault_secrets_officer
  ]
}