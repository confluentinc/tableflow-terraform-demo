terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

resource "confluent_catalog_integration" "unity_catalog" {

  environment {
    id = var.environment_id
  }
  kafka_cluster {
    id = var.kafka_cluster_id
  }
  display_name = "catalog-integration-snowflake"
  
  unity {
    catalog_name = var.catalog_name
    catalog_type = var.catalog_type
  }
  credentials {
    key    = var.tableflow_api_key
    secret = var.tableflow_api_secret
  }
  lifecycle {
    prevent_destroy = false
  }
}