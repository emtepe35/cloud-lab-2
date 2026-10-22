resource "azurerm_storage_account" "backend" {
  name                     = local.common.st_tfs
  resource_group_name      = azurerm_resource_group.common["common"].name
  location                 = azurerm_resource_group.common["common"].location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  blob_properties {
    versioning_enabled       = true
    last_access_time_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action = "Allow"
  }

  tags = merge(local.project_tags, {
    purpose    = "tfstate"
    managed_by = "opentofu"
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.backend.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_container" "backend" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.backend.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_management_policy" "backend" {
  storage_account_id = azurerm_storage_account.backend.id

  rule {
    name    = "tfstate-tiering"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["tfstate/"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_last_access_time_greater_than = 30
        auto_tier_to_hot_from_cool_enabled                          = true
        tier_to_cold_after_days_since_last_access_time_greater_than = 90
      }

      version {
        tier_to_cold_after_days_since_creation_greater_than = 0
        change_tier_to_archive_after_days_since_creation    = 14
        delete_after_days_since_creation                    = 194
      }
    }
  }
}

output "backend_config" {
  value = {
    resource_group_name  = azurerm_resource_group.common["common"].name
    storage_account_name = azurerm_storage_account.backend.name
    container_name       = azurerm_storage_container.backend.name
  }

  description = "Backend configuration for OpenTofu"
}