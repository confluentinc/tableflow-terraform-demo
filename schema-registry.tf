data "confluent_schema_registry_cluster" "essentials" {
  environment {
    id = confluent_environment.my_environment.id
  }

  depends_on = [
    confluent_kafka_cluster.kafka-cluster
  ]
}


resource "confluent_schema" "avro-stock-trades" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.essentials.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.essentials.rest_endpoint
  subject_name = "${confluent_kafka_topic.stock_trades.topic_name}-value"
  format = "AVRO"
  schema = file("./schemas/avro/stock_trades.avsc")
  credentials {
    key    = confluent_api_key.my-schema-registry-api-key.id
    secret = confluent_api_key.my-schema-registry-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
  depends_on = [confluent_role_binding.environment-admin, data.confluent_schema_registry_cluster.essentials]
}


resource "confluent_schema" "avro-users" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.essentials.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.essentials.rest_endpoint
  subject_name = "${confluent_kafka_topic.users.topic_name}-value"
  format = "AVRO"
  schema = file("./schemas/avro/users.avsc")
  credentials {
    key    = confluent_api_key.my-schema-registry-api-key.id
    secret = confluent_api_key.my-schema-registry-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
  depends_on = [confluent_role_binding.environment-admin, data.confluent_schema_registry_cluster.essentials]
}

