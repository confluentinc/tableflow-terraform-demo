# Common output - provider integration ID (works for both AWS and Azure)
output "provider_integration_internal_id" {
  description = "The internal ID for the provider integration."
  value = var.cloud_provider == "aws" ? confluent_provider_integration.aws[0].id : (
    var.cloud_provider == "azure" ? confluent_provider_integration_setup.azure[0].id : null
  )
}

# AWS-specific outputs
output "provider_integration_role_arn" {
  description = "The ARN of the provider integration IAM role (AWS only)."
  value       = var.cloud_provider == "aws" ? confluent_provider_integration.aws[0].aws[0].iam_role_arn : null
}

output "provider_integration_external_id" {
  description = "The external ID for the provider integration (AWS only)."
  value       = var.cloud_provider == "aws" ? confluent_provider_integration.aws[0].aws[0].external_id : null
}

# Azure-specific outputs
output "azure_confluent_multi_tenant_app_id" {
  description = "Confluent's multi-tenant application ID for Azure (Azure only). Use this to create the service principal."
  value       = var.cloud_provider == "azure" ? confluent_provider_integration_authorization.azure[0].azure[0].confluent_multi_tenant_app_id : null
}
