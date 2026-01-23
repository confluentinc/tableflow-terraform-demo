# Azure Service Principal for Tableflow BYOB Storage Access

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

# Application registration
resource "azuread_application" "tableflow" {
  display_name = "tableflow-sp-${var.catalog_name}-${var.random_suffix}"
}

# Service Principal
resource "azuread_service_principal" "tableflow" {
  client_id = azuread_application.tableflow.client_id
}

# Client Secret
resource "azuread_application_password" "tableflow" {
  application_id = azuread_application.tableflow.id
  display_name   = "Confluent Tableflow Access"
  end_date       = timeadd(timestamp(), "8760h") # 1 year from now
}

# Role assignment for storage blob data access
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.tableflow.object_id
}

# Additional role assignment for Databricks Unity Catalog if needed
resource "azurerm_role_assignment" "databricks_storage_access" {
  count                = var.catalog_name == "databricks" ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.tableflow.object_id
}
