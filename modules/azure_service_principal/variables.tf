variable "catalog_name" {
  description = "Name of the catalog (e.g., databricks, snowflake, fabric)"
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the Azure Storage Account to grant access to"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix to ensure uniqueness of service principal name"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}
