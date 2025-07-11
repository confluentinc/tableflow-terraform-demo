terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

resource "confluent_kafka_acl" "write_basic_cluster" {
  kafka_cluster {
    id = var.kafka_cluster_id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${var.service_account_id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = var.rest_endpoint
  credentials {
    key    = var.api_key
    secret = var.api_secret
  }

  lifecycle {
    prevent_destroy = false
  }
}