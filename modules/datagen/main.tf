terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

resource "confluent_connector" "datagen" {
  environment {
    id = var.environment_id
  }
  kafka_cluster {
    id = var.kafka_cluster_id
  }

  config_sensitive = var.config_sensitive

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = var.connector_name
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = var.service_account_id
    "kafka.topic"              = var.topic_name
    "output.data.format"       = var.output_data_format
    "quickstart"               = var.quickstart
    "tasks.max"                = var.tasks_max
    "max.interval"             = var.max_interval
  }

  lifecycle {
    prevent_destroy = false
  }
}

