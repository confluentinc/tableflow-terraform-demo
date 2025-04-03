variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}
variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "snowflake_endpoint" {
  description = "Snowflake endpoint"
  type        = string
  sensitive = true
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse"
  type        = string
}

variable snowflake_allowed_scope {
  description = "Snowflake allowed scope"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "us-east-1"
}

variable "catalog_type" {
  description = "The type of catalog integration to use (glue or snowflake)"
  type        = string
  default = "glue"
}

variable "polaris_client_id" {
  description = "Polaris Client ID"
  type        = string
  sensitive   = true
}

variable "polaris_client_secret" {
  description = "Polaris Client Secret"
  type        = string
  sensitive   = true
}

variable "environment_display_name" {
  description = "Display name for the environment"
  type        = string
}
