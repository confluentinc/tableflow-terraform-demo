variable "environment_id" {
  description = "The Confluent environment ID."
  type        = string
}

variable "kafka_cluster_id" {
  description = "The Confluent Kafka cluster ID."
  type        = string
}

variable "snowflake_endpoint" {
  description = "Snowflake endpoint URL."
  type        = string
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse name."
  type        = string
}

variable "snowflake_allowed_scope" {
  description = "Allowed scope for Snowflake integration."
  type        = string
}

variable "polaris_client_id" {
  description = "Polaris client ID for Snowflake integration."
  type        = string
}

variable "polaris_client_secret" {
  description = "Polaris client secret for Snowflake integration."
  type        = string
  sensitive   = true
}

variable "tableflow_api_key" {
  description = "API key for Tableflow."
  type        = string
}

variable "tableflow_api_secret" {
  description = "API secret for Tableflow."
  type        = string
  sensitive   = true
}