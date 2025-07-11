resource "confluent_service_account" "my_service_account" {
  display_name = "my-service-account-${random_integer.suffix.result}"
  description  = "Service Account for Tableflow talking to Kafka Cluster"
}

resource "confluent_role_binding" "environment_admin" {
  principal   = "User:${confluent_service_account.my_service_account.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = module.confluent_env_module.environment_crn
}

resource "confluent_role_binding" "cluster_admin" {
  for_each    = module.kafka_clusters
  principal   = "User:${confluent_service_account.my_service_account.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = each.value.rbac_crn
}

resource "confluent_role_binding" "all_topics_admin" {
  for_each    = module.kafka_clusters
  principal   = "User:${confluent_service_account.my_service_account.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${each.value.rbac_crn}/kafka=${each.value.cluster_id}/topic=*"
}