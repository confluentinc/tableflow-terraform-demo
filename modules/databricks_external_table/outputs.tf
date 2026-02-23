output "catalog_name" {
  description = "The name of the Unity Catalog catalog created by this module"
  value       = databricks_catalog.unity-demo-catalog.name
}

output "databricks_oauth_secret" {
  description = "The Databricks OAuth M2M secret for the service principal (use this as the client secret for Tableflow catalog integration)"
  value       = var.cloud_provider == "azure" ? databricks_service_principal_secret.tableflow_oauth[0].secret : null
  sensitive   = true
}
