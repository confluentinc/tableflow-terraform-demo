terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent" 
      version = "2.22.0"                
    }
  }
  }


resource "confluent_api_key" "kafka-api-key" {
  display_name = "kafka-api-key"
  description  = "Kafka API Key that is owned by 'my-service-account' service account"
  owner {
    id          = var.service_account_id
    api_version = var.service_account_api_version
    kind        = var.service_account_kind
  }

  managed_resource {
    id          = var.kafka_cluster_id
    api_version = var.kafka_api_version
    kind        = var.kafka_cluster_kind

    environment {
      id = var.environment_id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}