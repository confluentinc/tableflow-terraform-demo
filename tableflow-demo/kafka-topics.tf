resource "confluent_kafka_topic" "stock_trades" {
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  topic_name         = "stock_trades"
  rest_endpoint      = confluent_kafka_cluster.kafka-cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.kafka-api-key.id
    secret = confluent_api_key.kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "users" {
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  topic_name         = "users"
  rest_endpoint      = confluent_kafka_cluster.kafka-cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.kafka-api-key.id
    secret = confluent_api_key.kafka-api-key.secret
  }
}