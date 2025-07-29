<<<<<<< HEAD
# Confluent Cloud Variables
=======
>>>>>>> 5506fd838b1132463f707b5438fb32d6c974ede7
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}
variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

<<<<<<< HEAD
variable "environment_display_name" {
  description = "Display name for the environment"
  type        = string
}

variable "catalog_types" {
  description = "A list of catalog types (e.g., 'glue', 'snowflake', 'databricks') for which to provision resources. An empty list will provision no resources."
  type        = list(string)
  default     = ["glue", "snowflake", "databricks"]

  validation {
    condition = alltrue([
      for t in var.catalog_types : contains(["glue", "snowflake", "databricks"], t)
    ])
    error_message = "Each catalog_type must be one of: glue, snowflake, databricks."
  }
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


# Polaris Variables
=======
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

>>>>>>> 5506fd838b1132463f707b5438fb32d6c974ede7
variable "polaris_client_id" {
  description = "Polaris Client ID"
  type        = string
  sensitive   = true
<<<<<<< HEAD
  default     = "NULL"
}
=======
}

>>>>>>> 5506fd838b1132463f707b5438fb32d6c974ede7
variable "polaris_client_secret" {
  description = "Polaris Client Secret"
  type        = string
  sensitive   = true
<<<<<<< HEAD
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




# Databricks Variables

variable "databricks_workspace_id" {
  description = "The ID of the Databricks workspace"
  type        = string
  default     = "NULL"
}
variable "databricks_account_id" {
  description = "The account ID of the Databricks workspace"
  type        = string
  default     = "NULL"
}

variable "databricks_workspace_name" {
  description = "The name of the Databricks workspace"
  type        = string
  default     = "NULL"

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
  default     = "NULL"
}

variable "databricks_client_id" {
  description = "The client ID for Databricks OAuth"
  type        = string
  sensitive   = true
  default     = "NULL"
}
=======
}

variable "environment_display_name" {
  description = "Display name for the environment"
  type        = string
}
>>>>>>> 5506fd838b1132463f707b5438fb32d6c974ede7
