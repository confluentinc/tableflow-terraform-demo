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
  description = "The catalog type (e.g., glue, snowflake, databricks)."
  type        = string
}

variable "s3_bucket_name" {
  description = "The S3 bucket name for BYOB storage."
  type        = string
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
