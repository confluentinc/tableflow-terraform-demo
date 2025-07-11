variable "environment_id" {
  description = "The Confluent Cloud environment ID."
  type        = string
}

variable "schema_registry_api_key" {
  description = "API key for Schema Registry."
  type        = string
}

variable "schema_registry_api_secret" {
  description = "API secret for Schema Registry."
  type        = string
}

variable "stock_topic_name" {
  description = "The name of the stock trades topic."
  type        = string
}

variable "users_topic_name" {
  description = "The name of the users topic."
  type        = string
}