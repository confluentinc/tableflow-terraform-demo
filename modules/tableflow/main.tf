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

  # AWS BYOB configuration
  dynamic "byob_aws" {
    for_each = var.cloud_provider == "aws" ? [1] : []
    content {
      bucket_name             = var.storage_location_name
      provider_integration_id = var.provider_integration_id
    }
  }

  # Azure BYOB configuration
  # CRITICAL LIMITATION: As of Confluent provider v2.58.0, byob_azure is NOT supported
  # See AZURE_LIMITATION.md for details
  #
  # dynamic "byob_azure" {
  #   for_each = var.cloud_provider == "azure" ? [1] : []
  #   content {
  #     container_name          = var.storage_location_name
  #     storage_account_name    = var.azure_storage_account_name
  #     provider_integration_id = var.provider_integration_id
  #   }
  # }

  credentials {
    key    = var.api_key
    secret = var.api_secret
  }
}

