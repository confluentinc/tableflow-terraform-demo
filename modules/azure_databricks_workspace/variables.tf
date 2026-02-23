variable "workspace_name_suffix" {
  description = "Suffix for the Databricks workspace name"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "region" {
  description = "Azure region for the workspace"
  type        = string
}
