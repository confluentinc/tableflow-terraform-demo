# Microsoft Fabric Catalog Integration Module

This module provides integration between Confluent Tableflow and Microsoft Fabric for catalog management.

## Overview

**⚠️ Note**: This is currently a placeholder module. Full Confluent provider support for Microsoft Fabric catalog integration may require manual configuration steps. This module will be updated as the Confluent provider adds native support for Microsoft Fabric.

## Current Status

The Microsoft Fabric integration may require manual setup through:
1. Confluent Cloud UI
2. Azure Portal for Fabric workspace integration
3. Manual API calls to the Confluent Catalog API

## Future Usage (when fully supported)

```hcl
module "fabric_catalog_integration" {
  source                           = "./modules/fabric_catalog_integration"
  environment_id                   = confluent_environment.example.id
  catalog_type                     = "fabric"
  cluster_id                       = confluent_kafka_cluster.example.id
  provider_integration_internal_id = confluent_provider_integration.example.id
  tableflow_api_key                = var.tableflow_api_key
  tableflow_api_secret             = var.tableflow_api_secret
  azure_tenant_id                  = var.azure_tenant_id
  fabric_workspace_id              = var.fabric_workspace_id
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| environment_id | The ID of the Confluent Cloud environment | string | Yes |
| catalog_type | Type of catalog (should be 'fabric') | string | Yes |
| cluster_id | The ID of the Kafka cluster | string | Yes |
| provider_integration_internal_id | The internal ID of the provider integration | string | Yes |
| tableflow_api_key | Tableflow API key | string | Yes (sensitive) |
| tableflow_api_secret | Tableflow API secret | string | Yes (sensitive) |
| fabric_workspace_id | Microsoft Fabric workspace ID | string | No |
| azure_tenant_id | Azure Tenant ID for Fabric integration | string | No |

## Outputs

| Name | Description |
|------|-------------|
| catalog_integration_id | The ID of the Fabric catalog integration |
| catalog_integration_status | Status message about the integration |

## Manual Setup Steps

Until full provider support is available, you may need to:

1. **Create Fabric Workspace**: Set up a Microsoft Fabric workspace in the Azure Portal
2. **Configure Confluent Integration**: Use the Confluent Cloud UI to configure the Fabric catalog integration
3. **Grant Permissions**: Ensure the Service Principal has appropriate permissions on the Fabric workspace
4. **Verify Connection**: Test the integration through the Confluent Cloud UI

## Requirements

- Microsoft Fabric workspace
- Azure Service Principal with appropriate permissions
- Confluent Cloud environment and Kafka cluster
- Tableflow API credentials

## Roadmap

This module will be updated as the Confluent provider adds native support for Microsoft Fabric catalog integration. Expected features:

- Native Terraform resource for Fabric catalog integration
- Automated workspace configuration
- Sync status monitoring
- Table discovery and registration

## Alternative Approaches

While waiting for native support, consider:

1. **Databricks Unity Catalog**: Fully supported alternative for Azure deployments
2. **Snowflake Polaris**: Fully supported with ADLS storage
3. **Manual API Integration**: Use Confluent's REST APIs directly

## Resources

- [Microsoft Fabric Documentation](https://learn.microsoft.com/en-us/fabric/)
- [Confluent Cloud Documentation](https://docs.confluent.io/)
- [Azure Service Principal Setup](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
