# Azure ADLS Gen2 Storage Account and Container for Tableflow

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Get resource group data for outputs
data "azurerm_resource_group" "tableflow" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "adls" {
  name                     = "${var.storage_account_prefix}${var.catalog_name}${var.random_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true # Hierarchical namespace for ADLS Gen2

  tags = {
    Environment = "Tableflow"
    CatalogType = var.catalog_name
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_storage_container" "tableflow" {
  name                  = "tableflow-${var.catalog_name}"
  storage_account_name  = azurerm_storage_account.adls.name
  container_access_type = "private"
}
