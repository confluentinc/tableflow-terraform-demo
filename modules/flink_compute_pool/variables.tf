variable "environment_id" {
  description = "The ID of the Confluent Cloud environment."
  type        = string
}

variable "display_name" {
  description = "The display name for the Flink compute pool."
  type        = string
}

variable "cloud" {
  description = "The cloud provider for the Flink compute pool (e.g., aws, gcp, azure)."
  type        = string
  default = "AWS"
}

variable "region" {
  description = "The region for the Flink compute pool."
  type        = string
  default = "us-east-1"
}

variable "max_cfu" {
  description = "The maximum compute units for the Flink compute pool."
  type        = number
  default     = 5
}