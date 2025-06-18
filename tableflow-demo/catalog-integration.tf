resource "confluent_catalog_integration" "my_catalog" {
  count = var.catalog_type == "glue" ? 1 : 0
  environment {
    id = confluent_environment.my_environment.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  display_name = "catalog-integration-1"
  aws_glue {
    provider_integration_id = confluent_provider_integration.main.id
  }
  credentials {
    key    = confluent_api_key.my-tableflow-api-key.id
    secret = confluent_api_key.my-tableflow-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}



resource "confluent_catalog_integration" "snowflake_catalog" {
  count = var.catalog_type == "snowflake" ? 1 : 0

  environment {
    id = confluent_environment.my_environment.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  display_name = "catalog-integration-snowflake"
  snowflake {
    endpoint       = var.snowflake_endpoint
    warehouse      = var.snowflake_warehouse
    allowed_scope  = var.snowflake_allowed_scope
    client_id = var.polaris_client_id
    client_secret = var.polaris_client_secret
  }
  credentials {
    key    = confluent_api_key.my-tableflow-api-key.id
    secret = confluent_api_key.my-tableflow-api-key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

