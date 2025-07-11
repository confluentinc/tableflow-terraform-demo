variable "service_account_id" {
  description = "The ID of the service account that will own the API key."
  type        = string
}

variable "service_account_api_version" {
  description = "The API version of the service account."
  type        = string
}

variable "service_account_kind" {
  description = "The kind of the service account."
  type        = string
}

variable "kafka_cluster_id" {
  description = "The ID of the Kafka cluster for which the API key is created."
  type        = string
}

variable "kafka_api_version" {
  description = "The API version of the Kafka cluster."
  type        = string
}

variable "kafka_cluster_kind" {
  description = "The kind of the Kafka cluster."
  type        = string
}

variable "environment_id" {
  description = "The ID of the Confluent Cloud environment."
  type        = string
}