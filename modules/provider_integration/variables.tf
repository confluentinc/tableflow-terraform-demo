variable "environment_id" {
  description = "The ID of the Confluent Cloud environment."
  type        = string
}

variable "provider_name" {
  description = "The provider name or cluster type (e.g., glue, snowflake, databricks)."
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp)"
  type        = string
}

# AWS-specific variables
variable "customer_role_arn" {
  description = "The ARN of the customer S3 access IAM role (required only for AWS)."
  type        = string
  default     = null
}

# Azure-specific variables
variable "azure_tenant_id" {
  description = "Azure Tenant ID (required only for Azure)"
  type        = string
  default     = null
}