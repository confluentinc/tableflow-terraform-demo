variable "resource_group_name" {
  description = "The name of the Azure resource group"
  type        = string
}

variable "region" {
  description = "The Azure region for the access connector"
  type        = string
}

variable "name_suffix" {
  description = "Suffix to append to the access connector name for uniqueness"
  type        = string
}

variable "storage_account_id" {
  description = "The full resource ID of the Azure Storage Account to grant access to"
  type        = string
}
