# Azure Service Principal Module

This module creates an Azure Service Principal with appropriate role assignments for Tableflow BYOB (Bring Your Own Bucket) storage access.

## Overview

This module provisions:
- Azure AD Application registration
- Service Principal
- Application password (client secret)
- Role assignments for storage access:
  - Storage Blob Data Contributor (standard)
  - Storage Blob Data Owner (for Databricks Unity Catalog only)

## Usage

```hcl
module "azure_service_principal" {
  source             = "./modules/azure_service_principal"
  catalog_name       = "databricks"
  storage_account_id = azurerm_storage_account.example.id
  random_suffix      = "12345"
  azure_tenant_id    = "00000000-0000-0000-0000-000000000000"
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| catalog_name | Name of the catalog (e.g., databricks, snowflake, fabric) | string | Yes |
| storage_account_id | The ID of the Azure Storage Account to grant access to | string | Yes |
| random_suffix | Random suffix to ensure uniqueness | string | Yes |
| azure_tenant_id | Azure Tenant ID | string | Yes |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| client_id | The Application (Client) ID of the Service Principal | No |
| client_secret | The Client Secret for the Service Principal | Yes |
| tenant_id | The Azure Tenant ID | No |
| object_id | The Object ID of the Service Principal | No |
| application_id | The Application ID (same as client_id) | No |

## Role Assignments

### Standard Catalogs (Snowflake, Fabric)
- **Storage Blob Data Contributor**: Allows read, write, and delete access to blob data

### Databricks Unity Catalog
- **Storage Blob Data Owner**: Provides full access including ACL management, required for Unity Catalog external locations

## Notes

- The client secret is valid for 1 year from creation
- Service Principal names follow the format: `tableflow-sp-{catalog_name}-{random_suffix}`
- Role assignments may take a few seconds to propagate across Azure

## Requirements

- Azure subscription with permissions to:
  - Create Azure AD applications
  - Create service principals
  - Assign roles at the storage account level
- Azure AD provider version >= 2.0
- AzureRM provider version >= 3.0

## Security Considerations

- The client secret is marked as sensitive and should be stored securely
- Consider rotating the client secret periodically (currently set to 1 year)
- Role assignments follow the principle of least privilege
- For Databricks, the additional "Storage Blob Data Owner" role is only assigned when needed
