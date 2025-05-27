resource "confluent_api_key" "kafka-api-key" {
  display_name = "kafka-api-key"
  description  = "Kafka API Key that is owned by 'my-service-account' service account"
  owner {
    id          = confluent_service_account.my_service_account.id
    api_version = confluent_service_account.my_service_account.api_version
    kind        = confluent_service_account.my_service_account.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.kafka-cluster.id
    api_version = confluent_kafka_cluster.kafka-cluster.api_version
    kind        = confluent_kafka_cluster.kafka-cluster.kind

    environment {
      id = confluent_environment.my_environment.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
  depends_on = [confluent_role_binding.environment-example-rb]
}


resource "confluent_api_key" "my-schema-registry-api-key" {
  display_name = "my-schema-registry-api-key"
  description  = "Schema Registry API Key that is owned by 'my_service_account' service account"
  owner {
    id          = confluent_service_account.my_service_account.id
    api_version = confluent_service_account.my_service_account.api_version
    kind        = confluent_service_account.my_service_account.kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.essentials.id
    api_version = data.confluent_schema_registry_cluster.essentials.api_version
    kind        = data.confluent_schema_registry_cluster.essentials.kind

    environment {
      id = confluent_environment.my_environment.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    confluent_role_binding.environment-admin
  ]
}


# Tableflow API Keys
resource "confluent_api_key" "my-tableflow-api-key" {
  display_name = "app-manager-tableflow-api-key"
  description  = "Tableflow API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.my_service_account.id
    api_version = confluent_service_account.my_service_account.api_version
    kind        = confluent_service_account.my_service_account.kind
  }

  managed_resource {
    id          = "tableflow"
    api_version = "tableflow/v1"
    kind        = "Tableflow"

    environment {
      id = confluent_environment.my_environment.id
    }
  }
}
