terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

resource "confluent_catalog_integration" "snowflake_catalog" {

  environment {
    id = var.environment_id
  }
  kafka_cluster {
    id = var.kafka_cluster_id
  }
  display_name = "catalog-integration-snowflake"
  snowflake {
    endpoint       = var.snowflake_endpoint
    warehouse      = var.snowflake_warehouse
    allowed_scope  = var.snowflake_allowed_scope
    client_id      = var.polaris_client_id
    client_secret  = var.polaris_client_secret
  }
  credentials {
    key    = var.tableflow_api_key
    secret = var.tableflow_api_secret
  }
  lifecycle {
    prevent_destroy = false
  }
}