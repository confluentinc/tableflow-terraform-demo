output "confluent_service_principal_object_id" {
  description = "The Object ID of the Confluent multi-tenant service principal (used for Tableflow storage access)"
  value       = azuread_service_principal.confluent.object_id
}

output "databricks_client_id" {
  description = "The Application (Client) ID for Databricks Unity Catalog (null if not Databricks)"
  value       = local.is_databricks ? azuread_application.databricks[0].client_id : null
}

output "databricks_client_secret" {
  description = "The Client Secret for Databricks Unity Catalog (null if not Databricks)"
  value       = local.is_databricks ? azuread_application_password.databricks[0].value : null
  sensitive   = true
}

output "databricks_service_principal_object_id" {
  description = "The Object ID of the Databricks service principal (null if not Databricks)"
  value       = local.is_databricks ? azuread_service_principal.databricks[0].object_id : null
}
