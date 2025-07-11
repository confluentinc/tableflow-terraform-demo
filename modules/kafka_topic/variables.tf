variable "api_key" {
  description = "Confluent Cloud API key for authentication."
  type        = string
}

variable "api_secret" {
  description = "Confluent Cloud API secret for authentication."
  type        = string
}

variable "topic_name" {
  description = "Name of the Kafka topic to create."
  type        = string 
}

variable "cluster_id" {
  description = "Kafka cluster ID"
  type        = string
}

variable "rest_endpoint" {
  description = "Kafka REST endpoint"
  type        = string
}