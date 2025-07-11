output "environment_id" {
  description = "The ID of the Confluent Cloud environment."
  value       = confluent_environment.my_environment.id
}

output "environment_crn" {
  description = "The CRN of the Confluent Cloud environment."
  value       = confluent_environment.my_environment.resource_name
}
