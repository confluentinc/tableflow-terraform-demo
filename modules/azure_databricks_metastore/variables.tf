variable "workspace_id" {
  description = "The Databricks workspace ID (numeric)"
  type        = string
}

variable "workspace_resource_id" {
  description = "The Azure resource ID of the Databricks workspace (null for pre-existing workspaces)"
  type        = string
  default     = null
}

variable "databricks_account_id" {
  description = "The Databricks account ID"
  type        = string
}

variable "existing_metastore_id" {
  description = "Existing metastore ID to use (if provided, metastore creation is skipped)"
  type        = string
  default     = null
}

variable "storage_account_name" {
  description = "Name of the Azure storage account"
  type        = string
}

variable "container_name" {
  description = "Name of the ADLS container"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "azure_application_id" {
  description = "Azure service principal application ID (used when access_connector_id is null)"
  type        = string
  default     = null
}

variable "azure_client_secret" {
  description = "Azure service principal client secret (used when access_connector_id is null)"
  type        = string
  sensitive   = true
  default     = null
}

variable "azure_access_connector_id" {
  description = "Azure Databricks Access Connector resource ID (preferred over service principal)"
  type        = string
  default     = null
}

variable "create_sql_warehouse" {
  description = "Whether to create a SQL warehouse (true for auto-provisioned workspaces, false for pre-existing)"
  type        = bool
  default     = false
}

variable "sql_warehouse_name" {
  description = "Name for the SQL warehouse (if creating)"
  type        = string
  default     = "Starter Warehouse"
}

variable "region" {
  description = "Azure region"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for unique naming"
  type        = number
}

variable "skip_metastore_assignment" {
  description = "Skip metastore assignment (set to true for shared accounts where you lack admin permissions)"
  type        = bool
  default     = false
}
