# Azure ADLS Gen2 Container Module

This module creates an Azure Storage Account with hierarchical namespace enabled (ADLS Gen2) and a container for Tableflow data storage.

## Overview

This module provisions:
- Azure Storage Account with ADLS Gen2 enabled (hierarchical namespace)
- Storage container for Tableflow data
- Appropriate tags for resource management

## Usage

```hcl
module "azure_adls_container" {
  source                 = "./modules/azure_adls_container"
  catalog_name           = "databricks"
  resource_group_name    = "tableflow-rg"
  region                 = "eastus"
  storage_account_prefix = "cflttflow"
  random_suffix          = "12345"
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| catalog_name | Name of the catalog (e.g., databricks, snowflake) | string | Yes |
| resource_group_name | Name of the Azure Resource Group | string | Yes |
| region | Azure region for the storage account | string | Yes |
| storage_account_prefix | Prefix for the storage account name (3-15 lowercase alphanumeric) | string | Yes |
| random_suffix | Random suffix to ensure uniqueness | string | Yes |

## Outputs

| Name | Description |
|------|-------------|
| container_name | The name of the ADLS Gen2 container |
| storage_account_name | The name of the Azure Storage Account |
| storage_account_id | The ID of the Azure Storage Account |
| primary_blob_endpoint | The primary blob endpoint for the storage account |
| primary_dfs_endpoint | The primary DFS endpoint for ADLS Gen2 operations |

## Notes

- Storage account names must be globally unique across all of Azure
- The module uses the `random_suffix` to help ensure uniqueness
- The storage account is configured with:
  - Standard tier
  - Locally Redundant Storage (LRS)
  - Hierarchical namespace enabled for ADLS Gen2 compatibility
  - Private container access

## Requirements

- Azure subscription with permissions to create storage accounts
- Existing resource group
- Azure provider version >= 3.0
