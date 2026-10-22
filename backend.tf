terraform {
  backend "azurerm" {
    resource_group_name  = local.rg.common
    storage_account_name = local.common.st_tfs
    container_name       = "tfstate"
    key                  = "${local.year}/${var.project}/terraform.tfstate"
    use_azuread_auth     = true
  }
}