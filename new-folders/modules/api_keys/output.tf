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