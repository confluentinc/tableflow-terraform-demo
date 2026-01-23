output "catalog_integration_id" {
  description = "The ID of the Fabric catalog integration"
  value       = try(confluent_catalog_integration.fabric.id, "manual-setup-required")
}

output "catalog_integration_status" {
  description = "Status of the Fabric catalog integration"
  value       = "Placeholder - manual setup may be required"
}
