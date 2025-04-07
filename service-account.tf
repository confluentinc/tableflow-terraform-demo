resource "confluent_service_account" "my_service_account" {
  display_name = "my-service-account"
  description  = "Service Account for Tableflow talking to Kafka Cluster"
}

resource "confluent_role_binding" "environment-example-rb" {
  principal   = "User:${confluent_service_account.my_service_account.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.kafka-cluster.rbac_crn
}

resource "confluent_role_binding" "environment-admin" {
  principal   = "User:${confluent_service_account.my_service_account.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.my_environment.resource_name
}

resource "confluent_role_binding" "all-topics-admin" {
  principal   = "User:${confluent_service_account.my_service_account.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${confluent_kafka_cluster.kafka-cluster.rbac_crn}/kafka=${confluent_kafka_cluster.kafka-cluster.id}/topic=*"
}

resource "confluent_role_binding" "schema-developer-write" {
  principal   = "User:${confluent_service_account.my_service_account.id}"
  role_name   = "DeveloperWrite"
  crn_pattern = "${data.confluent_schema_registry_cluster.essentials.resource_name}/subject=*"
}

resource "confluent_role_binding" "assignee" {
  principal = "User:${confluent_service_account.my_service_account.id}"
  role_name = "Assigner"
  crn_pattern = "${data.confluent_organization.current.resource_name}/service-account=${confluent_service_account.my_service_account.id}"
}

