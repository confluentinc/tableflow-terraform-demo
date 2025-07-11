provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

provider "aws" {
  region = var.aws_region
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


data "aws_caller_identity" "current" {}

data "confluent_organization" "current" {}

data "databricks_current_user" "current_principal_from_workspace_provider" {
  count = contains(var.catalog_types, "databricks") ? 1 : 0
  provider = databricks.workspace
}



data "databricks_sql_warehouse" "my_existing_warehouse" {
  count = contains(var.catalog_types, "databricks") ? 1 : 0
  name = var.databricks_sql_warehouse_name
}

