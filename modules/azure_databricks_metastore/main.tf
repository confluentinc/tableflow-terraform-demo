locals {
  # Region mapping - Databricks metastore API expects lowercase without spaces
  # Just pass through the Azure region as-is (e.g., "eastus")
  databricks_region = var.region

  # Determine if we should create a new metastore or use existing
  create_metastore = var.existing_metastore_id == null

  # Use either the created metastore ID or the provided existing one
  metastore_id = local.create_metastore ? databricks_metastore.this[0].id : var.existing_metastore_id
}

# Create new metastore only if existing_metastore_id is not provided
resource "databricks_metastore" "this" {
  count    = local.create_metastore ? 1 : 0
  provider = databricks.workspace

  name         = "unity-metastore-${var.region}-${var.random_suffix}"
  region       = local.databricks_region
  storage_root = "abfss://${var.container_name}@${var.storage_account_name}.dfs.core.windows.net/metastore"

  force_destroy = true
}

# Create data access only if we're creating a new metastore
resource "databricks_metastore_data_access" "this" {
  count        = local.create_metastore ? 1 : 0
  provider     = databricks.workspace
  metastore_id = databricks_metastore.this[0].id
  name         = "unity-metastore-access-${var.random_suffix}"

  dynamic "azure_managed_identity" {
    for_each = var.azure_access_connector_id != null ? [1] : []
    content {
      access_connector_id = var.azure_access_connector_id
    }
  }

  dynamic "azure_service_principal" {
    for_each = var.azure_access_connector_id == null ? [1] : []
    content {
      directory_id   = var.azure_tenant_id
      application_id = var.azure_application_id
      client_secret  = var.azure_client_secret
    }
  }

  is_default = true
}

# Assign metastore to workspace (skip if user lacks admin permissions)
resource "databricks_metastore_assignment" "this" {
  count        = var.skip_metastore_assignment ? 0 : 1
  provider     = databricks.workspace
  workspace_id = var.workspace_id
  metastore_id = local.metastore_id
}

# SQL Warehouse for Unity Catalog queries (only for auto-provisioned workspaces)
resource "databricks_sql_endpoint" "unity" {
  count    = var.create_sql_warehouse ? 1 : 0
  provider = databricks.workspace

  name             = var.sql_warehouse_name
  cluster_size     = "2X-Small" # Smallest available size
  max_num_clusters = 1

  enable_photon             = true
  enable_serverless_compute = false # Classic compute (available in all regions)
  warehouse_type            = "PRO" # Required for Unity Catalog

  auto_stop_mins = 10 # Auto-suspend after 10 minutes idle

  tags {
    custom_tags {
      key   = "ManagedBy"
      value = "Terraform"
    }
    custom_tags {
      key   = "Environment"
      value = "Tableflow"
    }
  }
}
