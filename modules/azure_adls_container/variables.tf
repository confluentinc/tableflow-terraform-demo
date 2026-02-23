variable "catalog_name" {
  description = "Name of the catalog (e.g., databricks, snowflake)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "region" {
  description = "Azure region for the storage account"
  type        = string
}

variable "storage_account_prefix" {
  description = "Prefix for the storage account name (must be 3-15 lowercase alphanumeric characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,15}$", var.storage_account_prefix))
    error_message = "Storage account prefix must be 3-15 lowercase alphanumeric characters."
  }
}

variable "random_suffix" {
  description = "Random suffix to ensure uniqueness of storage account name"
  type        = string
}
