variable "cluster_name" {
  description = "The display name for the Kafka cluster."
  type        = string
}

variable "aws_region" {
  description = "The AWS region for the Kafka cluster."
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
