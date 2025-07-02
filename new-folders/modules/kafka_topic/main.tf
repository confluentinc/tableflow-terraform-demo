terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}


resource "confluent_kafka_topic" "kafka_topic" {
  kafka_cluster {
    id = var.cluster_id
  }
  topic_name         = var.topic_name
  rest_endpoint      = var.rest_endpoint
  credentials {
    key    = var.api_key
    secret = var.api_secret
  }
}