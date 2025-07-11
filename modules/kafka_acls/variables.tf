variable "kafka_cluster_id" {
  description = "The ID of the Kafka cluster."
  type        = string
}

variable "service_account_id" {
  description = "The ID of the service account for the ACL."
  type        = string
}

variable "rest_endpoint" {
  description = "The REST endpoint of the Kafka cluster."
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

