variable "environment_id" {
  description = "The Confluent Cloud environment ID."
  type        = string
}

variable "kafka_cluster_id" {
  description = "The Kafka cluster ID."
  type        = string
}

variable "topic_name" {
  description = "The name of the Kafka topic (and display name for the tableflow topic)."
  type        = string
}

variable "catalog_type" {
  description = "The catalog type (e.g., glue, snowflake, databricks, fabric)."
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp)"
  type        = string
}

variable "storage_location_name" {
  description = "The storage location name (S3 bucket name for AWS, container name for Azure)."
  type        = string
}

variable "azure_storage_account_name" {
  description = "Azure Storage Account name (required only for Azure)"
  type        = string
  default     = null
}

variable "provider_integration_id" {
  description = "The provider integration ID for BYOB storage."
  type        = string
}

variable "api_key" {
  description = "API key for the Kafka cluster."
  type        = string
}

variable "api_secret" {
  description = "API secret for the Kafka cluster."
  type        = string
}
