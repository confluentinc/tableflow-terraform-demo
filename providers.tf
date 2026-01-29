provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# AWS Provider (configured but only actively used for AWS deployments)
# When using Azure, we still need to configure AWS provider but it won't be used
provider "aws" {
  region = var.aws_region != null ? var.aws_region : (
    var.cloud_provider == "aws" ? var.region : "us-east-1"  # Default AWS region when using other clouds
  )
}

# Azure Resource Manager Provider (configured but not used - Azure not supported in Confluent provider v2.58.0)
# NOTE: Azure BYOB is not yet supported in Confluent Terraform provider.
# See AZURE_LIMITATION.md for details.
# These providers are configured to satisfy module requirements but won't be used when cloud_provider = "aws"

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = var.azure_subscription_id != "NULL" ? var.azure_subscription_id : null
}

provider "azuread" {
  tenant_id = var.azure_tenant_id != "NULL" ? var.azure_tenant_id : null
}


provider "snowflake" {
  account_name = var.polaris_account_name
  user         = var.polaris_username
  password     = var.polaris_password
}

provider "databricks" {
  alias = "workspace"
  host  = var.databricks_host
  token = var.databricks_token
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
}



data "databricks_sql_warehouse" "my_existing_warehouse" {
  count = contains(var.catalog_types, "databricks") ? 1 : 0
  name  = var.databricks_sql_warehouse_name
}

