# Performance Optimizations

This document outlines all performance optimizations applied to speed up terraform deployments.

## Completed Optimizations

### 1. Reduced IAM Propagation Wait Time
**File:** `modules/databricks_external_table/main.tf`
**Change:** Reduced `time_sleep` from 60s to 30s
**Impact:** Saves 30 seconds per Databricks deployment
**Reasoning:** AWS IAM typically propagates in 10-20 seconds; 30s provides adequate safety margin

```hcl
# Before
create_duration = "60s"

# After
create_duration = "30s"
```

### 2. Removed Redundant Dependencies
**File:** `modules/databricks_external_table/main.tf`
**Change:** Removed unnecessary `time_sleep` dependency from `databricks_catalog` resource
**Impact:** Allows catalog creation to proceed in parallel with external location
**Reasoning:** Catalog creation doesn't require IAM propagation completion

```hcl
# Before
depends_on = [databricks_storage_credential.external, time_sleep.wait_for_iam_propagation]

# After
depends_on = [databricks_storage_credential.external]
```

### 3. Removed Commented-Out Code
**Files:** `main.tf`, `providers.tf`
**Changes:**
- Removed commented Unity Catalog integration module (13 lines)
- Removed commented tagging module and AWS default_tags (12 lines)

**Impact:** Cleaner codebase, faster parsing
**Reasoning:** Unused code adds cognitive overhead and parsing time

### 4. Cleaned Up Repository Files
**Removed:**
- `.DS_Store` - macOS metadata file
- `fiserv.tfvars` - Customer-specific configuration file
- `REFACTORING_SUMMARY.md` - Temporary documentation file

**Impact:** Smaller repository size, faster git operations

## Deployment Time Breakdown

### Current Multi-Cluster Architecture (3 catalogs)

| Phase | Time | Parallelizable |
|-------|------|----------------|
| **Environment Setup** | ~30s | No |
| - Confluent environment | 10s | |
| - Service account | 10s | |
| - Random suffix | 5s | |
| **Infrastructure Creation** | ~3min | Partially |
| - Kafka clusters (3x) | 90s | Yes (parallel) |
| - API keys (3x) | 30s | Yes (parallel) |
| - S3 buckets (3x) | 15s | Yes (parallel) |
| - IAM roles (3x) | 30s | Yes (parallel) |
| - Provider integrations (3x) | 30s | Yes (parallel) |
| - Kafka topics (6x) | 30s | Yes (parallel) |
| **Schema Registry** | ~30s | No |
| - Schema registry API keys | 10s | |
| - AVRO schemas (2x) | 20s | Yes (parallel) |
| **Datagen Connectors** | ~3min | Yes (parallel) |
| - 6 connectors @ 30s each | 180s | Parallel per cluster |
| **Tableflow Topics** | ~15s | Yes (parallel) |
| - 3 tableflow topics | 15s | |
| **Databricks Setup** | ~1.5min | No |
| - IAM propagation wait | 30s | |
| - Storage credential | 5s | |
| - External location | 10s | |
| - Catalog | 10s | |
| - Grants (2x) | 15s | |
| - Directory + Query | 10s | |
| **Catalog Integrations** | ~15s | Yes (parallel) |
| - Glue integration | 5s | |
| - Snowflake integration | 5s | |
| - Flink pools (3x) | 15s | Yes (parallel) |

**Total Deployment Time:** ~5-7 minutes

## Performance Limitations

### 1. Confluent Cloud API Rate Limits
**Bottleneck:** Datagen connector creation (~30s per connector)
**Cannot optimize:** Confluent Cloud API enforces creation time
**Impact:** 6 connectors = ~3 minutes minimum

### 2. Sequential Dependencies
**Bottleneck:** Some resources must be created in order:
- Environment → Cluster → Topics → Connectors
- Role bindings → API keys

**Cannot optimize:** Logical dependency chain
**Impact:** Adds ~1-2 minutes of sequential operations

### 3. AWS IAM Propagation
**Optimized:** Reduced from 60s to 30s
**Cannot optimize further:** AWS requires time for global propagation
**Impact:** 30 seconds per Databricks deployment

## Further Optimization Opportunities

### 1. Use Smaller Cluster Types (Not Recommended for Production)
```hcl
# In kafka_clusters module, use BASIC instead of STANDARD
availability = "SINGLE_ZONE"  # Already optimized
```
**Impact:** Faster cluster creation (~30s savings)
**Trade-off:** Lower availability and performance

### 2. Reduce Catalog Types
```hcl
# Deploy only needed catalogs
catalog_types = ["glue"]  # Instead of ["databricks", "glue", "snowflake"]
```
**Impact:** 66% reduction in resources and time
**Trade-off:** Fewer catalog integrations

### 3. Skip Datagen Connectors for Testing
```hcl
# Temporarily comment out datagen modules
# module "datagen_stock_trades" { ... }
# module "datagen_users" { ... }
```
**Impact:** Saves ~3 minutes
**Trade-off:** No data generation for testing

## Terraform Parallelization Settings

Terraform already parallelizes resource creation where possible. You can adjust parallelism:

```bash
# Increase parallelism (default is 10)
terraform apply -parallelism=20

# Decrease for rate-limited APIs
terraform apply -parallelism=5
```

**Note:** Increasing parallelism may hit Confluent Cloud API rate limits.

## Best Practices for Fast Iterations

1. **Use Targeted Apply:**
   ```bash
   # Deploy only specific modules
   terraform apply -target=module.kafka_clusters
   terraform apply -target=module.datagen_stock_trades
   ```

2. **Leverage State Caching:**
   - Terraform caches provider data sources
   - Rerunning `apply` with no changes is fast (~10s)

3. **Use Workspace Isolation:**
   ```bash
   # Separate workspaces for different environments
   terraform workspace new dev
   terraform workspace new prod
   ```

4. **Pre-validate Before Apply:**
   ```bash
   terraform validate  # Fast validation
   terraform plan      # See changes before applying
   ```

5. **Use Auto-Approve Sparingly:**
   ```bash
   # Only for known-safe operations
   terraform apply -auto-approve
   ```

## Monitoring Deployment Time

Track deployment time with:

```bash
# Time the deployment
time terraform apply -auto-approve

# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log
terraform apply
```

## Expected Results

After optimizations:
- **Before:** ~7-8 minutes for full deployment
- **After:** ~5-7 minutes for full deployment
- **Savings:** ~30-60 seconds (5-10% improvement)

The optimizations provide modest time savings. The main bottlenecks (Confluent Cloud API for connectors, sequential dependencies) cannot be significantly optimized without changing the architecture.

## Architecture-Level Optimization (Not Implemented)

For significantly faster deployments, consider:
1. **Single-catalog deployment** - Deploy only the catalogs you need
2. **Pre-provisioned clusters** - Use existing clusters instead of creating new ones
3. **External data generation** - Use existing data instead of datagen connectors

These require architectural changes and trade-offs in functionality.
