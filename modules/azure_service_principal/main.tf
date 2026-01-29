# Azure Service Principal for Confluent Tableflow BYOB Storage Access
# This module creates a service principal for Confluent's multi-tenant application
# and grants it appropriate permissions on the ADLS storage account

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# Create service principal for Confluent's multi-tenant application
# The client_id comes from confluent_provider_integration_authorization.azure[0].confluent_multi_tenant_app_id
resource "azuread_service_principal" "confluent" {
  client_id = var.confluent_multi_tenant_app_id
}

# Role assignment for storage blob data access
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.confluent.object_id
}

# Additional role assignment for Databricks Unity Catalog if needed
resource "azurerm_role_assignment" "databricks_storage_access" {
  count                = var.catalog_name == "databricks" ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.confluent.object_id
}
