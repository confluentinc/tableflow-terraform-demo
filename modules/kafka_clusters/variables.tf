variable "cluster_name" {
  description = "The display name for the Kafka cluster."
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider for the Kafka cluster (aws, azure, gcp)"
  type        = string
}

variable "region" {
  description = "The cloud region for the Kafka cluster."
  type        = string
}

variable "environment_id" {
  description = "The Confluent Cloud environment ID."
  type        = string
}

variable "service_account_id" {
  description = "The ID of the service account for ACLs."
  type        = string
}
