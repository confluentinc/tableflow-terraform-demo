provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# AWS Provider (configured but only actively used for AWS deployments)
# When using Azure, we still need to configure AWS provider but it won't be used
provider "aws" {
  region = var.aws_region != null ? var.aws_region : (
    var.cloud_provider == "aws" ? var.region : "us-east-1" # Default AWS region when using other clouds
  )
}

# Azure Resource Manager Provider (configured but not used - Azure not supported in Confluent provider v2.58.0)
# NOTE: Azure BYOB is not yet supported in Confluent Terraform provider.
# See AZURE_LIMITATION.md for details.
# These providers are configured to satisfy module requirements but won't be used when cloud_provider = "aws"

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.azure_subscription_id != "NULL" ? var.azure_subscription_id : null
}

provider "azuread" {
  tenant_id = var.azure_tenant_id != "NULL" ? var.azure_tenant_id : null
}


provider "snowflake" {
  account_name = var.polaris_account_name
  user         = var.polaris_username
  password     = var.polaris_password
}

locals {
  # Determine if we need to auto-provision workspace
  # ONLY for Azure when databricks_workspace_url is not provided
  # databricks_host is AWS-specific and should not affect Azure auto-provisioning
  should_provision_workspace = (
    local.is_azure &&
    contains(var.catalog_types, "databricks") &&
    (var.databricks_workspace_url == null || var.databricks_workspace_url == "")
  )

  # Determine workspace URL to use
  # Priority: module output (if auto-provisioning) > workspace_url > databricks_host (AWS fallback)
  effective_workspace_url = (
    # Auto-provisioned Azure workspace
    local.should_provision_workspace
    ? module.azure_databricks_workspace[0].workspace_url
    # User-provided workspace URL (Azure pre-existing or AWS)
    : var.databricks_workspace_url != null && var.databricks_workspace_url != ""
    ? var.databricks_workspace_url
    # Legacy AWS workspace (databricks_host)
    : var.databricks_host
  )

  # Determine workspace resource ID for Azure (needed for AD auth)
  effective_workspace_resource_id = (
    local.should_provision_workspace
    ? module.azure_databricks_workspace[0].workspace_resource_id # Auto-provisioned
    : null                                                       # For pre-existing Azure workspace, we'll use token auth instead
  )

  # Determine workspace ID for metastore assignment
  effective_workspace_id = (
    local.should_provision_workspace
    ? module.azure_databricks_workspace[0].workspace_id # Auto-provisioned
    : var.databricks_workspace_id                       # User-provided
  )

  # Determine SQL warehouse ID to use
  # Only relevant when databricks is in catalog_types
  effective_sql_warehouse_id = (
    !contains(var.catalog_types, "databricks")
    ? null # Databricks not enabled - return null safely
    : local.should_provision_workspace
    ? module.azure_databricks_metastore[0].sql_warehouse_id     # Auto-created
    : data.databricks_sql_warehouse.my_existing_warehouse[0].id # Pre-existing
  )
}

provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id

  # ===================================================================
  # ACCOUNT PROVIDER - Handles account-level operations
  # ===================================================================
  # For Unity Catalog metastore creation/management
  #
  # AZURE: Uses Azure CLI authentication (automatic via `az login`)
  # - Leverages your current Azure login credentials
  # - No additional tokens or service principals needed
  # - Requires: Account Admin role in Databricks
  #
  # AWS: Uses account-level PAT token
  # - Set in terraform.tfvars: databricks_account_token = "dapi..."
  # ===================================================================

  # Azure: Let provider auto-detect Azure CLI credentials (no explicit auth params)
  # AWS: Use account-level PAT token
  token = local.is_azure ? null : (
    !contains(var.catalog_types, "databricks") ? null : coalesce(
      var.databricks_account_token != null && var.databricks_account_token != "" ? var.databricks_account_token : null,
      var.databricks_token != "NULL" && var.databricks_token != "" ? var.databricks_token : null
    )
  )
}

provider "databricks" {
  alias = "workspace"

  # ===================================================================
  # WORKSPACE PROVIDER - Handles workspace-level resources
  # ===================================================================
  # For SQL warehouses, external tables, queries, etc.
  #
  # MODE 1: Azure Auto-Provision
  #   - auth: Azure AD via azure_workspace_resource_id (requires az login)
  #   - token: null (not needed)
  #
  # MODE 2: Azure Pre-Existing OR AWS
  #   - auth: Workspace-level PAT token
  #   - token: databricks_workspace_token (or databricks_token for legacy)
  # ===================================================================

  # Use effective workspace URL (auto-provisioned, user-provided, or legacy)
  host = local.effective_workspace_url

  # Token logic:
  # - Azure auto-provisioned: null (use AD auth)
  # - Azure pre-existing or AWS: use workspace token
  token = (
    local.is_azure && contains(var.catalog_types, "databricks") && local.should_provision_workspace
    ? null # Auto-provisioned Azure uses AD auth
    : (
      !contains(var.catalog_types, "databricks") ? null : coalesce(
        var.databricks_workspace_token != null && var.databricks_workspace_token != "" ? var.databricks_workspace_token : null,
        var.databricks_token != "NULL" && var.databricks_token != "" ? var.databricks_token : null
      )
    )
  )

  # Azure AD authentication (only for auto-provisioned workspaces)
  azure_workspace_resource_id = (
    local.is_azure && contains(var.catalog_types, "databricks") && local.should_provision_workspace
    ? local.effective_workspace_resource_id
    : null
  )
}


# AWS data sources (conditional - only for AWS)
data "aws_caller_identity" "current" {
  count = var.cloud_provider == "aws" ? 1 : 0
}

# Azure data sources (configured but not used when cloud_provider = "aws")
data "azurerm_client_config" "current" {
  count = var.cloud_provider == "azure" ? 1 : 0
}

data "confluent_organization" "current" {}

data "databricks_current_user" "current_principal_from_workspace_provider" {
  count    = contains(var.catalog_types, "databricks") ? 1 : 0
  provider = databricks.workspace

  depends_on = [
    module.azure_databricks_workspace,
    module.azure_databricks_metastore
  ]
}

# SQL Warehouse lookup - only needed for pre-existing workspaces
# For auto-provisioned workspaces, we use the module output
data "databricks_sql_warehouse" "my_existing_warehouse" {
  count    = contains(var.catalog_types, "databricks") && !local.should_provision_workspace ? 1 : 0
  name     = var.databricks_sql_warehouse_name
  provider = databricks.workspace

  depends_on = [
    module.azure_databricks_workspace,
    module.azure_databricks_metastore
  ]
}

