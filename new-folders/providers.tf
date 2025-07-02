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


data "aws_caller_identity" "current" {}

data "confluent_organization" "current" {}

