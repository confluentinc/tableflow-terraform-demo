output "role_assignments" {
  description = "Map of role assignments created for Confluent service principal"
  value = {
    storage_blob_contributor = azurerm_role_assignment.storage_blob_data_contributor.id
    resource_group_reader    = azurerm_role_assignment.resource_group_reader.id
  }
}
