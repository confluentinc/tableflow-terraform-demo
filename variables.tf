# Confluent Cloud Variables
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}
variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

# Snowflake Variables
variable "snowflake_endpoint" {
  description = "Snowflake endpoint"
  type        = string
  sensitive   = true
  default     = "NULL"
}
variable "snowflake_warehouse" {
  description = "Snowflake warehouse"
  type        = string
  default     = "NULL"
}
variable "snowflake_allowed_scope" {
  description = "Snowflake allowed scope"
  type        = string
  default     = "NULL"
}
variable "snowflake_catalog_type" {
  type    = string
  default = "snowflake"
}
variable "snowflake_environment_display_name" {
  description = "Display name for the environment"
  type        = string
}

# Polaris Variables
variable "polaris_client_id" {
  description = "Polaris Client ID"
  type        = string
  sensitive   = true
  default     = "NULL"
}
variable "polaris_client_secret" {
  description = "Polaris Client Secret"
  type        = string
  sensitive   = true
  default     = "NULL"
}
variable "polaris_account_name" {
  description = "Polaris account name"
  type        = string
  default     = "NULL"
}
variable "polaris_username" {
  description = "Polaris username"
  type        = string
  default     = "NULL"
}
variable "polaris_password" {
  description = "Polaris password"
  type        = string
  sensitive   = true
  default     = "NULL"
}
variable "polaris_region" {
  description = "Polaris region"
  type        = string
  default     = "NULL"
}

# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Glue Variables
variable "glue_catalog_type" {
  type    = string
  default = "glue"
}
variable "glue_environment_display_name" {
  description = "Display name for the environment"
  type        = string
}

# Databricks Variables
variable "databricks_catalog_type" {
  type    = string
  default = "databricks"
}
variable "databricks_environment_display_name" {
  description = "Display name for the environment"
  type        = string
}
variable "databricks_workspace_id" {
  description = "The ID of the Databricks workspace"
  type        = string
  default     = "NULL"
}
variable "databricks_account_id" {
  description = "The account ID of the Databricks workspace"
  type        = string
  default = "NULL"
}

variable "databricks_workspace_name" {
  description = "The name of the Databricks workspace"
  type        = string
  default = "NULL"

}

variable "databricks_host" {
  description = "The host URL of the Databricks workspace"
  type        = string
  default     = "NULL"
}

variable "databricks_token" {
  description = "The token for the Databricks workspace"
  type        = string
  sensitive   = true
  default     = "NULL"
}

variable "databricks_sql_warehouse_name" {
  description = "The name of the Databricks SQL warehouse to use"
  type        = string
  default = "NULL"
}