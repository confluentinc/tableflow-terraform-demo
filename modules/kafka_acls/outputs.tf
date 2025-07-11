output "acl_id" {
  description = "The ID of the Kafka ACL."
  value       = confluent_kafka_acl.write_basic_cluster.id
}