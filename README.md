# Tableflow Terraform Demo

Terraform infrastructure-as-code for provisioning [Confluent Cloud Tableflow](https://docs.confluent.io/cloud/current/tableflow/overview.html) with support for **AWS** and **Azure**, and multiple catalog integrations.

## Architecture

![Architecture Diagram](tableflow-demo.drawio.png)

This project provisions:
- Confluent Cloud environment, Kafka clusters, topics, schema registry, and API keys
- Cloud storage (AWS S3 or Azure ADLS Gen2) with appropriate IAM/RBAC
- Catalog integrations for downstream analytics (Databricks, Snowflake, Glue)
- Sample data generators (datagen connectors) for `stock_trades` and `users` topics

## Supported Catalog Integrations

| Catalog Type | AWS | Azure | Notes |
|-------------|-----|-------|-------|
| **Databricks** (Unity Catalog) | Yes | Yes | Azure: fully auto-provisioned. AWS: requires existing workspace. |
| **Snowflake** (Polaris) | Yes | Yes | Requires Snowflake account and Polaris credentials. |
| **Glue** | Yes | -- | AWS only. Auto-provisioned, no extra config needed. |

## Prerequisites

**All deployments:**
- [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.0+
- [Confluent Cloud account](https://confluent.cloud/) with a Cloud API key
- [Confluent CLI](https://docs.confluent.io/confluent-cli/current/install.html) (run `confluent login`)

**AWS deployments:**
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured (`aws configure`)

**Azure deployments:**
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) configured (`az login`)
- An Azure resource group (or permissions to create one)

## Quick Start

```sh
git clone https://github.com/confluentinc/tableflow-terraform-demo
cd tableflow-project
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials (see the file for detailed guidance)
terraform init
terraform plan
terraform apply -auto-approve
```

When finished:
```sh
terraform destroy -auto-approve
```

---

## AWS Deployment Guide

### Minimal configuration

```hcl
# terraform.tfvars
confluent_cloud_api_key    = "your-key"
confluent_cloud_api_secret = "your-secret"
environment_display_name   = "Tableflow Demo"
cloud_provider             = "aws"
region                     = "us-east-1"
catalog_types              = ["databricks", "glue"]
```

### What gets provisioned

- S3 buckets (one per catalog type) for Tableflow data
- IAM roles with trust policies for Confluent Cloud
- Provider integration for secure cross-account access
- Glue catalog database (if `"glue"` in catalog_types)
- Databricks external location and storage credential (if `"databricks"` in catalog_types)

### Databricks on AWS

AWS requires an **existing** Databricks workspace. Add these to your `terraform.tfvars`:

```hcl
databricks_host               = "https://your-workspace.cloud.databricks.com"
databricks_token              = "your-personal-access-token"
databricks_workspace_id       = "1234567890"
databricks_workspace_name     = "your-workspace-name"
databricks_account_id         = "your-account-uuid"
databricks_sql_warehouse_name = "your-sql-warehouse"
databricks_client_id          = "your-oauth-client-id"
```

### Glue on AWS

No additional configuration needed. The Glue catalog database and permissions are auto-provisioned. Just include `"glue"` in `catalog_types`.

### Snowflake on AWS

Add Snowflake and Polaris credentials to your `terraform.tfvars`:

```hcl
snowflake_endpoint      = "https://your-account.us-east-1.snowflakecomputing.com"
snowflake_warehouse     = "your-warehouse"
snowflake_allowed_scope = "PRINCIPAL_ROLE:your-role"
polaris_client_id       = "your-polaris-client-id"
polaris_client_secret   = "your-polaris-client-secret"
polaris_account_name    = "your-polaris-account"
polaris_username        = "your-polaris-username"
polaris_password        = "your-polaris-password"
polaris_region          = "us-east-1"
```

---

## Azure Deployment Guide

### Minimal configuration

```hcl
# terraform.tfvars
confluent_cloud_api_key               = "your-key"
confluent_cloud_api_secret            = "your-secret"
environment_display_name              = "Tableflow Demo"
cloud_provider                        = "azure"
region                                = "eastus"
catalog_types                         = ["databricks"]
azure_subscription_id                 = "your-subscription-id"
azure_tenant_id                       = "your-tenant-id"
azure_resource_group_name             = "tableflow-rg"
azure_storage_account_name_prefix     = "cflttflow"
```

### What gets provisioned

- ADLS Gen2 storage account and container
- Azure AD service principal with Storage Blob Data Contributor role
- Databricks workspace (Premium SKU, auto-provisioned)
- Databricks Access Connector with system-assigned managed identity
- Unity Catalog metastore assigned to the workspace
- SQL warehouse (Pro, 2X-Small)
- Storage credential, external location, and catalog with full grants
- Databricks OAuth M2M secret for Tableflow authentication
- Provider integration for Confluent Cloud

### Databricks on Azure

**No Databricks configuration needed.** Everything is auto-provisioned, including:
- Workspace, metastore, access connector, service principal, SQL warehouse
- All Unity Catalog grants required for Tableflow
- Databricks OAuth M2M credentials

After `terraform apply`, retrieve the Tableflow catalog integration credentials:

```sh
terraform output azure_databricks_workspace_url   # Host
terraform output databricks_sp_client_id           # Client ID
terraform output databricks_oauth_secret           # Client Secret
terraform output databricks_catalog_name           # Catalog
```

Then in Confluent Cloud, create a **Databricks catalog integration**:

| Field | Source |
|-------|--------|
| Host | `terraform output azure_databricks_workspace_url` |
| Client ID | `terraform output databricks_sp_client_id` |
| Client Secret | `terraform output databricks_oauth_secret` |
| Catalog | `terraform output databricks_catalog_name` |

**Important:** The client secret must be the **Databricks OAuth M2M secret** (`databricks_oauth_secret`), not the Azure AD client secret (`databricks_sp_client_secret`). Confluent authenticates via Databricks OAuth (`/oidc/v1/token`), not Azure AD.

#### Unity Catalog permissions (auto-configured)

The service principal is granted these permissions automatically:

| Resource | Privileges |
|----------|-----------|
| Catalog | ALL_PRIVILEGES, EXTERNAL_USE_SCHEMA, MANAGE, CREATE_SCHEMA, CREATE_TABLE, SELECT, USE_CATALOG, USE_SCHEMA |
| External Location | ALL_PRIVILEGES, MANAGE, EXTERNAL_USE_LOCATION, CREATE_EXTERNAL_TABLE, READ_FILES, WRITE_FILES |
| Storage Credential | ALL_PRIVILEGES, MANAGE |

`account users` is also granted ALL_PRIVILEGES, BROWSE, EXTERNAL_USE_SCHEMA, MANAGE on the catalog and ALL_PRIVILEGES, EXTERNAL_USE_LOCATION, MANAGE on the external location.

### Snowflake on Azure

Works the same as AWS. Add Snowflake and Polaris credentials to your `terraform.tfvars`:

```hcl
snowflake_endpoint      = "https://your-account.east-us-2.azure.snowflakecomputing.com"
snowflake_warehouse     = "your-warehouse"
snowflake_allowed_scope = "PRINCIPAL_ROLE:your-role"
polaris_client_id       = "your-polaris-client-id"
polaris_client_secret   = "your-polaris-client-secret"
polaris_account_name    = "your-polaris-account"
polaris_username        = "your-polaris-username"
polaris_password        = "your-polaris-password"
polaris_region          = "eastus"
```

---

## Outputs

| Output | Description | Cloud |
|--------|-------------|-------|
| `confluent_environment_id` | Confluent Cloud environment ID | All |
| `kafka_cluster_ids` | Map of Kafka cluster IDs by name | All |
| `databricks_catalog_name` | Unity Catalog name for Tableflow | All (if databricks) |
| `databricks_sp_client_id` | Service principal application ID | Azure |
| `databricks_oauth_secret` | Databricks OAuth M2M secret for Tableflow | Azure |
| `databricks_sp_client_secret` | Azure AD client secret (not for Tableflow) | Azure |
| `azure_databricks_workspace_url` | Databricks workspace URL | Azure |
| `azure_databricks_workspace_id` | Databricks workspace numeric ID | Azure |
| `sql_warehouse_id` | SQL warehouse ID | Azure |
| `unity_metastore_id` | Unity Catalog metastore ID | Azure |
| `azure_access_connector_id` | Databricks Access Connector ID | Azure |
| `s3_bucket_names` | Map of S3 bucket names by cluster | AWS |
| `iam_role_names` | Map of IAM role names by cluster | AWS |

## Project Structure

```
.
├── main.tf                          # Main orchestration
├── variables.tf                     # Input variables
├── outputs.tf                       # Output definitions
├── providers.tf                     # Provider configuration
├── versions.tf                      # Terraform version constraints
├── role_bindings.tf                 # Confluent role bindings
├── random.tf                        # Random suffix generation
├── terraform.tfvars.example         # Example configuration
├── schemas/avro/                    # Avro schemas for topics
├── modules/
│   ├── confluent_environment/       # Confluent Cloud environment
│   ├── kafka_clusters/              # Kafka cluster provisioning
│   ├── kafka_topic/                 # Kafka topic creation
│   ├── api_keys/                    # API key generation
│   ├── schema_registry/             # Schema Registry
│   ├── schema_registry_api_keys/    # Schema Registry API keys
│   ├── datagen/                     # Data generator connectors
│   ├── tableflow/                   # Tableflow topic config
│   ├── tableflow_api_key/           # Tableflow API key
│   ├── provider_integration/        # Cloud provider integration
│   ├── flink_compute_pool/          # Flink compute pools
│   ├── aws_iam_role/                # AWS IAM roles
│   ├── aws_s3_bucket/               # AWS S3 buckets
│   ├── glue_catalog_integration/    # AWS Glue catalog
│   ├── azure_adls_container/        # Azure ADLS Gen2
│   ├── azure_service_principal/     # Azure AD service principal
│   ├── azure_databricks_workspace/  # Databricks workspace (Azure)
│   ├── azure_databricks_metastore/  # Unity Catalog metastore (Azure)
│   ├── azure_databricks_access_connector/ # Access connector (Azure)
│   ├── databricks_external_table/   # External tables, grants, OAuth secret
│   ├── unity_catalog_integration/   # Unity Catalog integration
│   └── snowflake_catalog_integration/ # Snowflake catalog
└── .github/workflows/              # CI/CD pipeline
```

## Testing

```sh
make test           # Run all tests (fmt + validate + lint)
make fmt            # Format Terraform files
make validate       # Validate configuration
make lint           # Run TFLint
make install-tools  # Install testing tools
```

Pre-commit hooks are available:

```sh
pre-commit install
pre-commit run --all-files
```

## Cost Warnings

This configuration provisions real cloud resources that incur costs:

- **Confluent Cloud:** Kafka clusters, connectors, Schema Registry, Tableflow, Flink compute pools
- **AWS:** S3 storage, data transfer
- **Azure:** ADLS Gen2 storage, Databricks workspace (Premium SKU), SQL warehouse (DBUs)
- **Databricks:** Unity Catalog, SQL warehouse compute
- **Snowflake:** Warehouse compute, storage (if enabled)

Run `terraform destroy` when finished to avoid ongoing charges.

## Troubleshooting

### Catalog integration returns 401 (Azure/Databricks)

Ensure you are using the **Databricks OAuth M2M secret** (`terraform output databricks_oauth_secret`), not the Azure AD client secret. Confluent authenticates via Databricks OAuth (`/oidc/v1/token`), not Azure AD.

### Catalog sync stuck in PENDING

Catalog integrations transition to SUCCESSFUL only after data is materialized in storage. This typically takes 5-10 minutes after deployment. Verify datagen connectors are running and producing to topics.

### IAM propagation delays (AWS)

The project includes a 30-second wait for IAM propagation. If you still get Access Denied errors, wait a few minutes and run `terraform apply` again.

### Duplicate service principals in Databricks (Azure)

The `databricks_service_principal` resource uses `force = true` to take ownership of any pre-existing SP with the same application ID. If you see duplicates in the Databricks UI after multiple destroy/apply cycles, they may be stale account-level entries that can be safely deleted from the UI.

### Terraform init fails

```sh
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Debug mode

```sh
export TF_LOG=DEBUG
terraform apply
unset TF_LOG
```

## Contributing

Fork the repository and submit a pull request with your changes.

## License

[Apache License 2.0](LICENSE.txt)
