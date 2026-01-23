# AWS-specific outputs
output "provider_integration_role_arn" {
  description = "The ARN of the provider integration IAM role (AWS only)."
  value       = var.cloud_provider == "aws" ? confluent_provider_integration.main.aws[0].iam_role_arn : null
}

output "provider_integration_external_id" {
  description = "The external ID for the provider integration (AWS only)."
  value       = var.cloud_provider == "aws" ? confluent_provider_integration.main.aws[0].external_id : null
}

# Azure-specific outputs
output "azure_tenant_id" {
  description = "Azure tenant ID (Azure only)."
  value       = var.cloud_provider == "azure" ? var.azure_tenant_id : null
}

output "azure_application_id" {
  description = "Azure application ID (Azure only)."
  value       = var.cloud_provider == "azure" ? var.azure_application_id : null
}

# Common outputs
output "provider_integration_internal_id" {
  description = "The internal ID for the provider integration."
  value       = confluent_provider_integration.main.id
}