# outputs.tf
output "confluent_environment_id" {
  description = "The ID of the Confluent Cloud environment."
  value       = module.confluent_env_module.environment_id
}

output "kafka_cluster_ids" {
  description = "A map of all Kafka cluster IDs, keyed by cluster name."
  value       = { for k, m in module.kafka_clusters : k => m.cluster_id }
}

output "iam_role_names" {
  description = "A map of all IAM role names created, keyed by cluster name."
  value       = { for k, m in module.aws_iam_role : k => m.role_name }
}

output "s3_bucket_names" {
  description = "A map of all S3 bucket names created, keyed by cluster name."
  value       = { for k, m in module.aws_s3_bucket : k => m.bucket_name }
}

output "azure_databricks_workspace_url" {
  description = "The URL of the Azure Databricks workspace (if auto-provisioned)"
  value       = local.should_provision_workspace ? module.azure_databricks_workspace[0].workspace_url : null
}

output "azure_databricks_workspace_id" {
  description = "The ID of the Azure Databricks workspace (if auto-provisioned)"
  value       = local.should_provision_workspace ? module.azure_databricks_workspace[0].workspace_id : null
}

output "unity_metastore_id" {
  description = "The Unity Catalog metastore ID (if created)"
  value       = local.is_azure && contains(var.catalog_types, "databricks") ? module.azure_databricks_metastore[0].metastore_id : null
}

output "sql_warehouse_id" {
  description = "The SQL warehouse ID (if auto-created)"
  value       = local.should_provision_workspace ? module.azure_databricks_metastore[0].sql_warehouse_id : null
}

output "databricks_catalog_name" {
  description = "The Unity Catalog name to use when creating a Databricks catalog integration in Confluent Cloud"
  value       = contains(var.catalog_types, "databricks") ? module.databricks_external_table[0].catalog_name : null
}

output "databricks_kafka_cluster_id" {
  description = "The Kafka cluster ID for the Databricks catalog (needed for manual catalog integration)"
  value       = contains(var.catalog_types, "databricks") ? module.kafka_clusters["databricks"].cluster_id : null
}

output "azure_access_connector_id" {
  description = "The Azure Databricks Access Connector resource ID (if created)"
  value       = local.is_azure && contains(var.catalog_types, "databricks") ? module.azure_databricks_access_connector[0].access_connector_id : null
}

output "databricks_sp_client_id" {
  description = "The Application (Client) ID of the Databricks service principal (for Tableflow catalog integration)"
  value       = local.is_azure && contains(var.catalog_types, "databricks") ? module.azure_service_principal["databricks"].databricks_client_id : null
}

output "databricks_sp_client_secret" {
  description = "The Azure AD Client Secret of the Databricks service principal"
  value       = local.is_azure && contains(var.catalog_types, "databricks") ? module.azure_service_principal["databricks"].databricks_client_secret : null
  sensitive   = true
}

output "databricks_oauth_secret" {
  description = "The Databricks OAuth M2M secret (use this as the client secret for Tableflow catalog integration)"
  value       = local.is_azure && contains(var.catalog_types, "databricks") ? module.databricks_external_table[0].databricks_oauth_secret : null
  sensitive   = true
}
