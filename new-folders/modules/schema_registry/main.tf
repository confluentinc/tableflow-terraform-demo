terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}


data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = var.environment_id
  }


}


resource "confluent_schema" "avro-stock-trades" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.essentials.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.essentials.rest_endpoint
  subject_name = "${var.stock_topic_name}-value"
  format = "AVRO"
  schema = file("${path.module}/schemas/avro/stock_trades.avsc")
  credentials {
    key    = var.schema_registry_api_key
    secret = var.schema_registry_api_secret
  }

  lifecycle {
    prevent_destroy = false
  }
}


resource "confluent_schema" "avro-users" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.essentials.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.essentials.rest_endpoint
  subject_name = "${var.users_topic_name}-value"
  format = "AVRO"
  schema = file("${path.module}/schemas/avro/users.avsc")
  credentials {
    key    = var.schema_registry_api_key
    secret = var.schema_registry_api_secret
  }

  lifecycle {
    prevent_destroy = false
  }
  
}

