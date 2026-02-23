variable "storage_credential_name" {
  description = "The name for the Databricks storage credential."
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp)"
  type        = string
}

# AWS-specific variables
variable "aws_iam_role_arn" {
  description = "The ARN of the AWS IAM role to use for Databricks (required only for AWS)."
  type        = string
  default     = null
}

variable "iam_role_id" {
  description = "The ID of the IAM role."
  type        = string
}

variable "iam_policy_id" {
  description = "The ID of the IAM policy."
  type        = string
}

variable "iam_policy_attachment_id" {
  description = "The ID of the IAM policy attachment."
  type        = string
}

variable "external_location_name" {
  description = "The name for the Databricks external location."
  type        = string
}

variable "storage_location_name" {
  description = "The storage location name (S3 bucket name for AWS, container name for Azure)."
  type        = string
}

# Azure-specific variables
variable "azure_tenant_id" {
  description = "Azure Tenant ID (required only for Azure)"
  type        = string
  default     = null
}

variable "azure_access_connector_id" {
  description = "Azure Databricks Access Connector resource ID (preferred over service principal for Azure)"
  type        = string
  default     = null
}

variable "azure_application_id" {
  description = "Azure Application (Client) ID (required only for Azure)"
  type        = string
  default     = null
}

variable "azure_client_secret" {
  description = "Azure Client Secret (required only for Azure)"
  type        = string
  sensitive   = true
  default     = null
}

variable "container_name" {
  description = "Azure ADLS container name (required only for Azure)"
  type        = string
  default     = null
}

variable "storage_account_name" {
  description = "Azure Storage Account name (required only for Azure)"
  type        = string
  default     = null
}

variable "catalog_type" {
  description = "The catalog type (should be 'databricks' for this module)."
  type        = string
}

variable "grant_principals" {
  description = "List of principals to grant privileges to (e.g. service principal application IDs, user emails)."
  type        = list(string)
  default     = []
}

variable "databricks_sp_application_id" {
  description = "The Azure AD application (client) ID of the Databricks service principal to register in the workspace (Azure only)."
  type        = string
  default     = null
}

variable "shared_dir_path" {
  description = "The path for the shared directory in Databricks."
  type        = string
}

variable "sql_warehouse_id" {
  description = "The ID of the Databricks SQL warehouse."
  type        = string
}

variable "query_display_name" {
  description = "The display name for the Databricks query."
  type        = string
}

variable "databricks_host" {
  description = "The host URL of the Databricks workspace."
  type        = string
  default     = "NULL"
}

variable "databricks_token" {
  description = "The token for the Databricks workspace."
  type        = string
  sensitive   = true
  default     = "NULL"
}

variable "confluent_organization_id" {
  description = "The Confluent organization ID."
  type        = string
  default     = "NULL"
}

variable "confluent_environment_id" {
  description = "The Confluent environment ID."
  type        = string
  default     = "NULL"
}

variable "confluent_cluster_id" {
  description = "The Confluent cluster ID."
  type        = string
  default     = "NULL"
}

variable "kafka_topic_id" {
  description = "The Kafka topic ID."
  type        = string
  default     = "NULL"
}

variable "random_suffix" {
  description = "A random suffix to append to resource names."
  type        = string
  default     = "string"
}