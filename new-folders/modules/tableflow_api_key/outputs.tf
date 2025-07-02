output "api_key" {
  description = "The API key for Tableflow."
    value       = confluent_api_key.my-tableflow-api-key.id
    sensitive = false
}

output "api_secret" {
  description = "The API secret for Tableflow."
  value       = confluent_api_key.my-tableflow-api-key.secret
    sensitive   = true
}