variable "catalog_type" {
  description = "The catalog type, should be 'glue' to enable this integration."
  type        = string
}

variable "environment_id" {
  description = "The Confluent Cloud environment ID."
  type        = string
}

variable "cluster_id" {
  description = "The Kafka cluster ID."
  type        = string
}

variable "provider_integration_internal_id" {
  description = "The internal ID of the provider integration for AWS Glue."
  type        = string
}

variable "tableflow_api_key" {
  description = "API key for Tableflow."
  type        = string
}

variable "tableflow_api_secret" {
  description = "API secret for Tableflow."
  type        = string
}