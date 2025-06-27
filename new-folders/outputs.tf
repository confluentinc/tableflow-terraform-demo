# outputs.tf

output "confluent_environment_id" {
  description = "The ID of the Confluent Cloud environment."
  value       = module.confluent_env_module.environment_id
}

output "kafka_cluster_ids" {
  description = "A map of all Kafka cluster IDs, keyed by cluster name."
  value       = { for k, m in module.kafka_clusters : k => m.cluster_id }
}
