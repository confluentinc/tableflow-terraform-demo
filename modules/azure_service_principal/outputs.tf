output "client_id" {
  description = "The Application (Client) ID of the Service Principal"
  value       = azuread_application.tableflow.client_id
}

output "client_secret" {
  description = "The Client Secret for the Service Principal"
  value       = azuread_application_password.tableflow.value
  sensitive   = true
}

output "tenant_id" {
  description = "The Azure Tenant ID"
  value       = var.azure_tenant_id
}

output "object_id" {
  description = "The Object ID of the Service Principal"
  value       = azuread_service_principal.tableflow.object_id
}

output "application_id" {
  description = "The Application ID (same as client_id)"
  value       = azuread_application.tableflow.client_id
}
