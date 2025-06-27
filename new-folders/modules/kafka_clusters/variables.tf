variable cluster_name {
  description = "Name of the Confluent Cloud Kafka cluster to create."
  type        = string
}

variable environment_id {
  description = "ID of the Confluent Cloud environment where the Kafka cluster will be created."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the Kafka cluster will be created."
  type        = string
  
}