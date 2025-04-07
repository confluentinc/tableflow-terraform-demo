resource "confluent_kafka_acl" "write-basic-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.my_service_account.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.kafka-cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.kafka-api-key.id
    secret = confluent_api_key.kafka-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}