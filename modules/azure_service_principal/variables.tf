variable "confluent_multi_tenant_app_id" {
  description = "Confluent's multi-tenant application ID from provider_integration_authorization"
  type        = string
}

variable "catalog_name" {
  description = "Name of the catalog (e.g., databricks, snowflake, fabric)"
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the Azure Storage Account to grant access to"
  type        = string
}
