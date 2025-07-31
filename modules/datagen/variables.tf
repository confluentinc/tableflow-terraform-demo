variable "environment_id" {
  description = "The Confluent Cloud environment ID."
  type        = string
}

variable "kafka_cluster_id" {
  description = "The Kafka cluster ID."
  type        = string
}

variable "service_account_id" {
  description = "The service account ID for the connector."
  type        = string
}

variable "topic_name" {
  description = "The Kafka topic to produce to."
  type        = string
}

variable "output_data_format" {
  description = "The output data format (e.g., AVRO, JSON)."
  type        = string
}

variable "quickstart" {
  description = "The Datagen quickstart to use (e.g., STOCK_TRADES, USERS)."
  type        = string
}

variable "connector_name" {
  description = "The name of the connector."
  type        = string
}

variable "tasks_max" {
  description = "The maximum number of tasks."
  type        = string
  default     = "1"
}

variable "max_interval" {
  description = "The max interval for the datagen connector."
  type        = string
  default     = "10"
}

variable "config_sensitive" {
  description = "Sensitive config map for the connector."
  type        = map(string)
  default     = {}
}