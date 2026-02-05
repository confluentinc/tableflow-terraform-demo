output "container_name" {
  description = "The name of the ADLS Gen2 container"
  value       = azurerm_storage_container.tableflow.name
}

output "storage_account_name" {
  description = "The name of the Azure Storage Account"
  value       = azurerm_storage_account.adls.name
}

output "storage_account_id" {
  description = "The ID of the Azure Storage Account"
  value       = azurerm_storage_account.adls.id
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint for the storage account"
  value       = azurerm_storage_account.adls.primary_blob_endpoint
}

output "primary_dfs_endpoint" {
  description = "The primary DFS endpoint for ADLS Gen2 operations"
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = data.azurerm_resource_group.tableflow.id
}
