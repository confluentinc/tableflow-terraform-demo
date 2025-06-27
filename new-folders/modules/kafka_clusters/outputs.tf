output "cluster_id" {
  description = "The ID of the Confluent Cloud Cluster."
  value       = confluent_kafka_cluster.my_cluster.id
}

output "rest_endpoint" {
  description = "The REST endpoint of the Kafka cluster."
  value       = confluent_kafka_cluster.my_cluster.rest_endpoint
}

output "rbac_crn" {
  description = "The RBAC CRN of the Kafka cluster."
  value       = confluent_kafka_cluster.my_cluster.rbac_crn
}

output "api_version" {
  description = "The API version of the Kafka cluster."
  value       = confluent_kafka_cluster.my_cluster.api_version
}

output "kind" {
  description = "The kind of the Kafka cluster."
  value       = confluent_kafka_cluster.my_cluster.kind
}