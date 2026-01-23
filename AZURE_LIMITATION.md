# Azure Support Limitation

## Critical Finding

**As of Confluent Terraform Provider v2.58.0, Azure BYOB for Tableflow is NOT supported.**

## What Doesn't Work

The following Confluent Terraform resources do not have Azure support:

### 1. `confluent_provider_integration`
- ❌ No `azure` block available
- ✅ Only `aws` block supported
- **Impact**: Cannot create provider integration for Azure storage

### 2. `confluent_tableflow_topic`
- ❌ No `byob_azure` block available
- ✅ Only `byob_aws` block supported
- **Impact**: Cannot configure Azure ADLS as Tableflow storage

### 3. `confluent_catalog_integration`
- ❌ No `fabric` catalog type support
- ✅ Only `aws_glue` and `snowflake` supported
- **Impact**: Cannot integrate with Microsoft Fabric catalog

## Current Status

The multi-cloud implementation in this repository includes:
- ✅ **Azure infrastructure modules** (ADLS, Service Principal) - WORKING
- ❌ **Confluent Azure integration** - NOT SUPPORTED in Terraform provider

## Workarounds

Until Azure support is added to the Confluent Terraform provider, you must configure Azure BYOB manually:

### Option 1: Confluent Cloud UI
1. Create Azure storage and service principal (can use our Terraform modules)
2. Manually configure provider integration in Confluent Cloud UI
3. Manually configure Tableflow with Azure BYOB in UI

### Option 2: Confluent Cloud REST API
Use the Confluent Cloud REST API directly to configure:
- Provider Integration with Azure credentials
- Tableflow topics with Azure BYOB

### Option 3: Wait for Provider Update
Monitor Confluent provider releases for Azure support:
- https://github.com/confluentinc/terraform-provider-confluent/releases
- https://registry.terraform.io/providers/confluentinc/confluent/latest

## What We Built

This repository contains a **prepared multi-cloud architecture** ready for when Azure support is added:

### Infrastructure Layer (✅ Ready)
- `modules/azure_adls_container/` - ADLS Gen2 storage
- `modules/azure_service_principal/` - Service Principal with RBAC
- Azure provider configuration
- Cloud-aware variable structure

### Integration Layer (❌ Blocked)
- Provider integration (needs Confluent provider update)
- Tableflow BYOB configuration (needs Confluent provider update)
- Fabric catalog integration (needs Confluent provider update)

## Recommendation

**For now, continue using AWS** for Tableflow with Terraform automation.

### Current Working Configuration
```hcl
# terraform.tfvars
cloud_provider = "aws"
region = "us-east-1"
catalog_types = ["databricks", "snowflake", "glue"]
```

### Future Azure Configuration (when supported)
```hcl
# terraform.tfvars
cloud_provider = "azure"
region = "eastus"
catalog_types = ["databricks", "snowflake", "fabric"]
azure_subscription_id = "..."
azure_tenant_id = "..."
```

## Testing Done

1. ✅ Azure CLI authentication - WORKING
2. ✅ Azure resource group creation - WORKING
3. ✅ Azure ADLS module - READY (not tested with Confluent)
4. ✅ Azure Service Principal module - READY (not tested with Confluent)
5. ❌ Confluent provider integration - BLOCKED (not supported)
6. ❌ Tableflow BYOB with Azure - BLOCKED (not supported)

## Next Steps

1. **Short-term**: Use AWS for Tableflow automation
2. **Monitor**: Watch for Confluent provider updates
3. **Ready**: Code is prepared for Azure when provider adds support
4. **Alternative**: Use UI/API for manual Azure configuration

## Provider Version Tested

- Confluent Provider: v2.58.0
- Azure RM Provider: v4.58.0
- Azure AD Provider: v3.7.0

## References

- Confluent Provider Docs: https://registry.terraform.io/providers/confluentinc/confluent/latest/docs
- Feature Request: Consider opening GitHub issue for Azure support
- Confluent Cloud API: https://docs.confluent.io/cloud/current/api.html

---

**Last Updated**: January 23, 2026
**Status**: Azure BYOB not supported in Terraform provider
