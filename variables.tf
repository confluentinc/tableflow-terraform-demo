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

variable "environment_display_name" {
  description = "Display name for the environment"
  type        = string
}

# Cloud Provider Configuration
variable "cloud_provider" {
  description = "Cloud provider for infrastructure deployment"
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, azure, gcp."
  }
}

variable "catalog_types" {
  description = "A list of catalog types (e.g., 'glue', 'snowflake', 'databricks', 'fabric') for which to provision resources. An empty list will provision no resources. Note: 'glue' is AWS-only, 'fabric' is Azure-only."
  type        = list(string)
  default     = ["glue", "snowflake", "databricks"]

  validation {
    condition = alltrue([
      for t in var.catalog_types : contains(["glue", "snowflake", "databricks", "fabric"], t)
    ])
    error_message = "Each catalog_type must be one of: glue, snowflake, databricks, fabric."
  }
}


# Snowflake Variables
variable "snowflake_endpoint" {
  description = "Snowflake endpoint"
  type        = string
  sensitive   = true
  default     = "NULL"

  validation {
    condition     = var.snowflake_endpoint == "NULL" || can(regex("^https://.*\\.snowflakecomputing\\.com$", var.snowflake_endpoint))
    error_message = "Must be a valid Snowflake endpoint URL (e.g., https://account.region.snowflakecomputing.com) or 'NULL'."
  }
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

# Region Configuration
variable "region" {
  description = "Cloud region for infrastructure deployment. Format varies by cloud provider: AWS (e.g., us-east-1), Azure (e.g., eastus), GCP (e.g., us-central1)"
  type        = string
  default     = "us-east-1"

  validation {
    condition = (
      can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region)) || # AWS format
      can(regex("^[a-z]+[a-z0-9]*$", var.region)) ||          # Azure format
      can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))          # GCP format
    )
    error_message = "Must be a valid cloud region format. AWS: us-east-1, Azure: eastus, GCP: us-central1"
  }
}

# Deprecated: Use 'region' instead. Kept for backward compatibility.
variable "aws_region" {
  description = "DEPRECATED: Use 'region' instead. AWS region for backward compatibility."
  type        = string
  default     = null
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

  validation {
    condition     = var.databricks_host == "NULL" || can(regex("^https://.*\\.cloud\\.databricks\\.com", var.databricks_host))
    error_message = "Must be a valid Databricks workspace URL (e.g., https://dbc-xxxxx-yyyy.cloud.databricks.com) or 'NULL'."
  }
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

# Azure Configuration (only required when cloud_provider = "azure")
variable "azure_subscription_id" {
  description = "Azure Subscription ID (required only if cloud_provider = azure)"
  type        = string
  default     = "NULL"
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID (required only if cloud_provider = azure, can be auto-detected from az CLI)"
  type        = string
  default     = "NULL"
}

variable "azure_resource_group_name" {
  description = "Azure Resource Group name for ADLS storage (only if cloud_provider = azure)"
  type        = string
  default     = "tableflow-rg"
}

variable "azure_storage_account_name_prefix" {
  description = "Prefix for Azure Storage Account name (only if cloud_provider = azure). Must be 3-15 lowercase alphanumeric characters."
  type        = string
  default     = "cflttflow"

  validation {
    condition     = var.azure_storage_account_name_prefix == "cflttflow" || can(regex("^[a-z0-9]{3,15}$", var.azure_storage_account_name_prefix))
    error_message = "Storage account prefix must be 3-15 lowercase alphanumeric characters."
  }
}