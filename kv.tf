resource "azurerm_key_vault" "this" {
  name                        = local.common.kv
  location                    = azurerm_resource_group.common["common"].location
  resource_group_name         = azurerm_resource_group.common["common"].name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enabled_for_disk_encryption = true
  rbac_authorization_enabled  = true

  tags = local.project_tags

  lifecycle {
    prevent_destroy = true
  }
}