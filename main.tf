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

provider "snowflake" {
  account_name  = var.polaris_account_name
  user = var.polaris_username
  password = var.polaris_password
}

provider "databricks" {
  account_id = var.databricks_account_id
}

# module "tableflow-demo-with-glue"{
#   source = "./tableflow-demo"
#   confluent_cloud_api_key = var.confluent_cloud_api_key
#   confluent_cloud_api_secret = var.confluent_cloud_api_secret
#   aws_region = var.aws_region
#   catalog_type = var.glue_catalog_type
#   environment_display_name = var.glue_environment_display_name
# }

# module "tableflow-demo-with-snowflake"{
#   source = "./tableflow-demo"
#   polaris_account_name = var.polaris_account_name
#   polaris_username = var.polaris_username
#   polaris_password = var.polaris_password
#   confluent_cloud_api_key = var.confluent_cloud_api_key
#   confluent_cloud_api_secret = var.confluent_cloud_api_secret
#   snowflake_endpoint = var.snowflake_endpoint
#   snowflake_warehouse = var.snowflake_warehouse
#   snowflake_allowed_scope = var.snowflake_allowed_scope
#   aws_region = var.aws_region
#   catalog_type = var.snowflake_catalog_type
#   environment_display_name = var.snowflake_environment_display_name
#   polaris_client_id = var.polaris_client_id
#   polaris_client_secret = var.polaris_client_secret
#   polaris_region = var.polaris_region
# }

module "tableflow-demo-with-databricks"{
  source = "./tableflow-demo"
  confluent_cloud_api_key = var.confluent_cloud_api_key
  confluent_cloud_api_secret = var.confluent_cloud_api_secret
  aws_region = var.aws_region
  catalog_type = var.databricks_catalog_type
  environment_display_name = var.databricks_environment_display_name
  databricks_account_id = var.databricks_account_id
  databricks_workspace_id = var.databricks_workspace_id
  databricks_workspace_name = var.databricks_workspace_name
  databricks_host = var.databricks_host
  databricks_token = var.databricks_token
  databricks_sql_warehouse_name = var.databricks_sql_warehouse_name
}