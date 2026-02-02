output "object_id" {
  description = "The Object ID of the Service Principal"
  value       = local.is_databricks ? azuread_service_principal.databricks[0].object_id : azuread_service_principal.confluent[0].object_id
}

output "client_id" {
  description = "The Application (Client) ID of the Service Principal"
  value       = local.is_databricks ? azuread_application.databricks[0].client_id : var.confluent_multi_tenant_app_id
}

output "client_secret" {
  description = "The Client Secret (only available for Databricks)"
  value       = local.is_databricks ? azuread_application_password.databricks[0].value : null
  sensitive   = true
}
