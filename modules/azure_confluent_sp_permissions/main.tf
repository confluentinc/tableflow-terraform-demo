# Azure Confluent Multi-Tenant Service Principal Permissions
# This module grants the Confluent service principal necessary permissions
# for Tableflow to access Azure Data Lake Storage Gen2

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0, < 5.0.0"
    }
  }
}

# Grant Storage Blob Data Contributor role for data writes
# Note: This is the primary role needed for Tableflow to write Iceberg data
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.confluent_service_principal_object_id

  # Skip AAD check as the service principal may not be fully replicated yet
  skip_service_principal_aad_check = true

  timeouts {
    create = "5m"
    delete = "5m"
  }
}

# Grant Reader role on resource group for resource discovery
# Required for Tableflow to verify the storage account exists
resource "azurerm_role_assignment" "resource_group_reader" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = var.confluent_service_principal_object_id

  skip_service_principal_aad_check = true

  timeouts {
    create = "5m"
    delete = "5m"
  }
}
