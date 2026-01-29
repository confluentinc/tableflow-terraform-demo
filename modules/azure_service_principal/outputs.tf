output "object_id" {
  description = "The Object ID of the Service Principal"
  value       = azuread_service_principal.confluent.object_id
}

output "client_id" {
  description = "The Application (Client) ID of the Service Principal (Confluent's multi-tenant app)"
  value       = var.confluent_multi_tenant_app_id
}
