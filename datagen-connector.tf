# https://github.com/confluentinc/terraform-provider-confluent/tree/master/examples/configurations/connectors/managed-datagen-source-connector
resource "confluent_connector" "stock_datagen" {
  environment {
    id = confluent_environment.my_environment.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_0"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.my_service_account.id
    "kafka.topic"              = confluent_kafka_topic.stock_trades.topic_name
    "output.data.format"       = "AVRO"
    "quickstart"               = "STOCK_TRADES"
    "tasks.max"                = "1"
    "max.interval"             = "10"
  }

  depends_on = [
    confluent_kafka_acl.write-basic-cluster
  ]

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_connector" "users_datagen" {
  environment {
    id = confluent_environment.my_environment.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }

  config_sensitive = {}

  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "DatagenSourceConnector_1"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.my_service_account.id
    "kafka.topic"              = confluent_kafka_topic.users.topic_name
    "output.data.format"       = "AVRO"
    "quickstart"               = "USERS"
    "tasks.max"                = "1"
    "max.interval"             = "10"
  }

  depends_on = [
    confluent_kafka_acl.write-basic-cluster
  ]

  lifecycle {
    prevent_destroy = false
  }
}

