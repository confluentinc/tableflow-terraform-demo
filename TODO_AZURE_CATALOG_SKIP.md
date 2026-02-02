# TODO: Azure Support Without Catalog Integrations

## Goal
Make catalog integrations fully optional for Azure deployments while maintaining full AWS functionality.

---

## Code Changes Required

### 1. Main Configuration (main.tf)

**Current Issue:**
- `module.azure_service_principal` creates for ALL clusters (line 228-238)
- Databricks external table module tries to use service principal secrets
- Tableflow module depends on azure_service_principal

**Changes Needed:**
```hcl
# Line 228-238: Only create service principals for catalog types that need them
module "azure_service_principal" {
  for_each = local.is_azure ? {
    for k, v in module.kafka_clusters : k => v
    if contains(local.azure_catalog_types_needing_sp, k)
  } : {}
  # ... rest of config
}

# Add to locals (line 2-9):
locals {
  # Catalog types that need service principals on Azure
  # Currently: none, until Confluent adds support
  azure_catalog_types_needing_sp = []

  # Or in future when supported:
  # azure_catalog_types_needing_sp = ["databricks", "fabric"]
}
```

### 2. Variables (variables.tf)

**Change validation to allow empty catalog_types:**
```hcl
variable "catalog_types" {
  description = "A list of catalog types. Can be empty for Azure deployments testing storage only."
  type        = list(string)
  default     = []  # Changed from ["glue", "snowflake", "databricks"]

  validation {
    condition = alltrue([
      for t in var.catalog_types : contains(["glue", "snowflake", "databricks", "fabric"], t)
    ])
    error_message = "Each catalog_type must be one of: glue, snowflake, databricks, fabric."
  }
}
```

### 3. Databricks External Table Module

**Skip when on Azure:**
```hcl
# Line 329-372: Add Azure skip condition
module "databricks_external_table" {
  count = (
    contains(var.catalog_types, "databricks") &&
    var.cloud_provider == "aws"  # Only on AWS for now
  ) ? 1 : 0

  # ... rest of config
}
```

### 4. Tableflow Module Dependencies

**Make azure_service_principal dependency conditional:**
```hcl
# Line 266-274
depends_on = [
  module.aws_iam_role,
  # Only depend on azure_service_principal if any were created
  # module.azure_service_principal,  # Remove unconditional dependency
  module.kafka_topic_stock_trades,
  module.tableflow_api_key,
  data.confluent_schema_registry_cluster.essentials,
  module.datagen_stock_trades,
  module.provider_integration
]
```

### 5. Outputs (outputs.tf)

**Make outputs conditional:**
```hcl
# Need to check what Azure-specific outputs exist and make conditional
# Add count/for_each checks to avoid errors when resources don't exist
```

---

## Testing Strategy

### Test Scenarios

1. **Azure with empty catalog_types** ✅
   ```hcl
   cloud_provider = "azure"
   catalog_types = []
   ```
   Expected: Storage + Confluent infrastructure, no catalog integrations

2. **AWS with glue + snowflake** (Regression) ✅
   ```hcl
   cloud_provider = "aws"
   catalog_types = ["glue", "snowflake", "databricks"]
   ```
   Expected: Full deployment with all catalog integrations

3. **AWS with empty catalog_types** (Edge case)
   ```hcl
   cloud_provider = "aws"
   catalog_types = []
   ```
   Expected: Storage + Confluent infrastructure, no catalog integrations

### Validation Commands
```bash
# Test 1: Azure simplified
cat > test-azure.tfvars <<EOF
cloud_provider = "azure"
catalog_types = []
region = "eastus"
azure_subscription_id = "..."
azure_tenant_id = "..."
EOF
terraform plan -var-file=test-azure.tfvars

# Test 2: AWS full (regression)
cat > test-aws.tfvars <<EOF
cloud_provider = "aws"
catalog_types = ["glue", "snowflake", "databricks"]
region = "us-east-1"
EOF
terraform plan -var-file=test-aws.tfvars

# Test 3: AWS simplified
cat > test-aws-simple.tfvars <<EOF
cloud_provider = "aws"
catalog_types = []
region = "us-east-1"
EOF
terraform plan -var-file=test-aws-simple.tfvars
```

---

## Subagent Review Tasks

### Before Making Changes
- [ ] Review current dependencies between modules
- [ ] Identify all references to azure_service_principal
- [ ] Identify all catalog integration modules and their dependencies
- [ ] Map out what resources are needed for "storage-only" deployment

### After Making Changes
- [ ] Review modified code for correctness
- [ ] Check for any broken dependencies
- [ ] Verify conditional logic is correct
- [ ] Ensure no hardcoded assumptions about catalog_types

---

## Risks & Mitigations

### Risk 1: Breaking AWS Deployments
**Mitigation:** Thorough regression testing with AWS configs

### Risk 2: Incomplete Azure Deployment
**Mitigation:** Clear documentation of what's included/excluded

### Risk 3: Complex Conditional Logic
**Mitigation:** Use clear local variables with descriptive names

### Risk 4: State File Issues
**Mitigation:** Test with fresh state, document migration if needed

---

## Future Enhancements

When Confluent adds Azure catalog integration support:

1. **Update azure_catalog_types_needing_sp:**
   ```hcl
   azure_catalog_types_needing_sp = ["databricks", "fabric"]
   ```

2. **Enable Databricks module for Azure:**
   ```hcl
   count = contains(var.catalog_types, "databricks") ? 1 : 0
   # Remove cloud_provider == "aws" restriction
   ```

3. **Add Azure-specific catalog integrations:**
   - Microsoft Fabric when supported
   - Unity Catalog with managed identities (alternative to service principals)

---

## Files to Modify

- [x] `main.tf` - Conditional service principal creation, module dependencies
- [x] `variables.tf` - Allow empty catalog_types, update defaults
- [x] `outputs.tf` - Make Azure-specific outputs conditional
- [ ] `modules/azure_service_principal/` - Already handles conditional logic
- [ ] `modules/provider_integration/` - Should already work conditionally
- [ ] Documentation - Update README with Azure limitations

---

## Open Questions

1. Should we keep Fabric storage resources even though catalog integration isn't supported?
   - **Recommendation:** Remove for now, add back when Confluent adds support

2. Should provider_integration authorization work without service principals?
   - **Current:** It's failing because it needs service principals
   - **Solution:** Check if we can skip authorization step for testing

3. What's the minimum needed for Tableflow to write to Azure storage?
   - Provider integration setup ✅
   - Storage account + container ✅
   - Service principal ❌ (needs admin)
   - Provider integration authorization ❌ (depends on SP)

---

## Estimated Effort

- Code changes: 1-2 hours
- Testing: 1 hour
- Documentation: 30 minutes
- Subagent review: 30 minutes

**Total: 3-4 hours**

---

## Success Criteria

✅ Azure deployment works with `catalog_types = []`
✅ AWS deployment still works with all catalog types
✅ No hardcoded assumptions about catalog types
✅ Clear error messages if invalid configuration
✅ Documentation updated with Azure limitations
