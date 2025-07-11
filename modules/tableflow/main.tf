terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

resource "confluent_tableflow_topic" "this" {
  environment {
    id = var.environment_id
  }
  kafka_cluster {
    id = var.kafka_cluster_id
  }
  display_name = var.topic_name

  # Set table format based on catalog_type
  table_formats = var.catalog_type == "databricks" ? ["DELTA", "ICEBERG"] : ["ICEBERG"]

  byob_aws {
    bucket_name             = var.s3_bucket_name
    provider_integration_id = var.provider_integration_id
  }

  credentials {
    key    = var.api_key
    secret = var.api_secret
  }
}

