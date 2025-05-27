terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent" 
      version = "2.22.0"                
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.17.0"
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 1.0.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

provider "aws" {
  region = var.aws_region
}

provider "databricks" {
  alias = "workspace"
  host  = var.databricks_host
  token = var.databricks_token
}

provider "databricks" {
  alias         = "mws"
  account_id    = var.databricks_account_id
  host          = "https://accounts.cloud.databricks.com"
}

data "aws_caller_identity" "current" {}

data "confluent_organization" "current" {}

data "databricks_current_user" "current_principal_from_workspace_provider" {
  count = var.catalog_type == "databricks" ? 1 : 0
  # Explicitly link this data source to the provider instance with alias "workspace"
  provider = databricks.workspace
}


data "databricks_sql_warehouse" "my_existing_warehouse" {
  count = var.catalog_type == "databricks" ? 1 : 0
  name = var.databricks_sql_warehouse_name
}

