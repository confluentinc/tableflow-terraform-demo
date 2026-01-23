variable "environment_id" {
  description = "The ID of the Confluent Cloud environment"
  type        = string
}

variable "catalog_type" {
  description = "Type of catalog (should be 'fabric')"
  type        = string
  default     = "fabric"
}

variable "cluster_id" {
  description = "The ID of the Kafka cluster"
  type        = string
}

variable "provider_integration_internal_id" {
  description = "The internal ID of the provider integration"
  type        = string
}

variable "tableflow_api_key" {
  description = "Tableflow API key"
  type        = string
  sensitive   = true
}

variable "tableflow_api_secret" {
  description = "Tableflow API secret"
  type        = string
  sensitive   = true
}

# Future variables for when Fabric support is fully implemented
variable "fabric_workspace_id" {
  description = "Microsoft Fabric workspace ID (optional, for future use)"
  type        = string
  default     = null
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID for Fabric integration"
  type        = string
  default     = null
}
