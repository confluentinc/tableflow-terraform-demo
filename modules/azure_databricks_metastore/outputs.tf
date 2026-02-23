output "metastore_id" {
  description = "The ID of the Unity Catalog metastore (created or existing)"
  value       = local.metastore_id
}

output "metastore_name" {
  description = "The name of the Unity Catalog metastore (null if using existing)"
  value       = local.create_metastore ? databricks_metastore.this[0].name : null
}

output "sql_warehouse_id" {
  description = "The ID of the SQL warehouse (if created)"
  value       = var.create_sql_warehouse ? databricks_sql_endpoint.unity[0].id : null
}
