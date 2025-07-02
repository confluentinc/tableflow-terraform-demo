output "api_key" {
  description = "The API key for Schema Registry."
  value       = confluent_api_key.my-schema-registry-api-key.id
}

output "api_secret" {
  description = "The API secret for Schema Registry."
  value       = confluent_api_key.my-schema-registry-api-key.secret
}