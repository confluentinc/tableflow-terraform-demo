variable "environment_id" {
  description = "The ID of the Confluent Cloud environment."
  type        = string
}

variable "kafka_cluster_id" {
  description = "The ID of the Kafka cluster in Confluent Cloud."
  type        = string
}

variable "tableflow_api_key" {
  description = "API key for Tableflow integration."
  type        = string
}

variable "tableflow_api_secret" {
  description = "API secret for Tableflow integration."
  type        = string
}

variable "catalog_name" {
  description = "The name of the Unity Catalog."
  type        = string
}

variable "catalog_type" {
  description = "The type of the catalog (e.g., databricks, snowflake, glue)."
  type        = string
}