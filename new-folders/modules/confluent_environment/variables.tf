variable "environment_name" {
  description = "Name of the Confluent Cloud environment to create."
  type        = string
}

variable "confluent_api_key" {
  description = "Confluent Cloud API key for authentication."
  type        = string
}

variable "confluent_api_secret" {
  description = "Confluent Cloud API secret for authentication."
  type        = string
}