output "api_key" {
  description = "The API key for the Kafka cluster."
  value       = confluent_api_key.kafka-api-key.id
  sensitive   = true
}

output "api_secret" {
  description = "The API secret for the Kafka cluster."
  value       = confluent_api_key.kafka-api-key.secret
  sensitive   = true
}

output "schema_registry_api_key" {
  description = "The API key for the Schema Registry."
  value       = confluent_api_key.my-schema-registry-api-key.id
  sensitive   = true
}

output "schema_registry_api_secret" {
  description = "The API secret for the Schema Registry."
  value       = confluent_api_key.my-schema-registry-api-key.secret
  sensitive   = true
}