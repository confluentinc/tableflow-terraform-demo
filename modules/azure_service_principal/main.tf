# Azure Service Principal for Confluent Tableflow BYOB Storage Access
# This module creates either:
# 1. Service principal for Confluent's multi-tenant app (for most catalogs)
# 2. Dedicated Azure AD application with secret (for Databricks Unity Catalog)

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
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}

locals {
  is_databricks = var.catalog_name == "databricks"
}

# For Databricks: Create a dedicated Azure AD application
resource "azuread_application" "databricks" {
  count        = local.is_databricks ? 1 : 0
  display_name = "tableflow-databricks-${var.catalog_name}"
}

resource "azuread_service_principal" "databricks" {
  count     = local.is_databricks ? 1 : 0
  client_id = azuread_application.databricks[0].client_id
}

resource "time_rotating" "databricks_secret_rotation" {
  count         = local.is_databricks ? 1 : 0
  rotation_days = 365
}

resource "azuread_application_password" "databricks" {
  count                 = local.is_databricks ? 1 : 0
  application_id        = azuread_application.databricks[0].id
  display_name          = "tableflow-databricks-secret"
  end_date_relative     = "8760h" # 1 year
  rotate_when_changed = {
    rotation = time_rotating.databricks_secret_rotation[0].id
  }
}

# For other catalogs: Create service principal for Confluent's multi-tenant application
resource "azuread_service_principal" "confluent" {
  count     = local.is_databricks ? 0 : 1
  client_id = var.confluent_multi_tenant_app_id
}

# Role assignment for Databricks
resource "azurerm_role_assignment" "databricks_storage_access" {
  count                = local.is_databricks ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.databricks[0].object_id
}

# Role assignment for Confluent (non-Databricks)
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  count                = local.is_databricks ? 0 : 1
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.confluent[0].object_id
}
