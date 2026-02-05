variable "confluent_service_principal_object_id" {
  description = "The Object ID of the Confluent service principal (from azure_service_principal module)"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.confluent_service_principal_object_id))
    error_message = "Service principal object ID must be a valid GUID."
  }
}

variable "storage_account_id" {
  description = "The full resource ID of the Azure Storage Account to grant access to"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Storage/storageAccounts/[^/]+$", var.storage_account_id))
    error_message = "Storage account ID must be a valid Azure resource ID format."
  }
}

variable "resource_group_id" {
  description = "The full resource ID of the Azure Resource Group for resource discovery"
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", var.resource_group_id))
    error_message = "Resource group ID must be a valid Azure resource ID format."
  }
}
