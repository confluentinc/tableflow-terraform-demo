output "workspace_id" {
  description = "The unique identifier of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_url" {
  description = "The URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "workspace_resource_id" {
  description = "The Azure resource ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.id
}
