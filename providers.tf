provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# AWS Provider (works for both AWS and Azure deployments, but only actively used for AWS)
provider "aws" {
  region = var.aws_region != null ? var.aws_region : var.region
}

# Azure Resource Manager Provider (only used when cloud_provider = azure)
provider "azurerm" {
  features {}
  subscription_id            = var.cloud_provider == "azure" ? var.azure_subscription_id : null
  skip_provider_registration = true
}

# Azure Active Directory Provider (only used when cloud_provider = azure)
provider "azuread" {
  tenant_id = var.cloud_provider == "azure" ? var.azure_tenant_id : null
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

# Azure data sources (conditional - only for Azure)
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

