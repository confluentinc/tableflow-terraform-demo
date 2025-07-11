# Tableflow Project

This project contains Terraform scripts to provision and configure resources for a data pipeline using AWS and Confluent Cloud. The pipeline integrates Kafka topics, IAM roles, S3 storage, and Confluent Tableflow for managing data streams and schemas. **This project is designed for demonstration purposes and supports integration with AWS Glue or Snowflake for downstream data processing.**

## Overview

The Terraform scripts in this project perform the following tasks:
- Create Kafka topics (`stock_trades` and `users`) in Confluent Cloud.
- Configure a Datagen Source Connector to generate sample data for the `stock_trades` and `users` topics.
- Set up an S3 bucket and IAM roles/policies for BYOB (Bring Your Own Bucket) integration with Confluent Tableflow.
- Provision a Confluent Tableflow topic (`stock_trades`) with Iceberg table format.
- Manage API keys for Kafka and Tableflow access

## Architecture
![](tableflow-demo.drawio.png)

## Prerequisites

Before using these scripts, ensure you have:
1. **AWS Account**: Required for S3 bucket and IAM role creation.
2. Make sure you configure your aws account locally by running `aws configure`
3. **Confluent Cloud Account**: Required for Kafka, Tableflow, and connector provisioning.

## Required Variables

You need to define the following variables in a `variables.tf` file or provide them via environment variables or a `.tfvars` file:

### Confluent Cloud Variables (Required)
- `confluent_cloud_api_key` (string): Confluent Cloud API Key
- `confluent_cloud_api_secret` (string, sensitive): Confluent Cloud API Secret

### Environment Display Names (Required)
- `glue_environment_display_name` (string): Display name for the Glue environment
- `snowflake_environment_display_name` (string, optional): Display name for the Snowflake environment
- `databricks_environment_display_name` (string, optional): Display name for the Databricks environment

### AWS Variables (Required)
- `aws_region` (string): AWS region

### Snowflake Variables (Optional, for Snowflake integration)
- `snowflake_endpoint` (string, sensitive): Snowflake endpoint
- `snowflake_warehouse` (string): Snowflake warehouse
- `snowflake_allowed_scope` (string): Snowflake allowed scope (e.g., `PRINCIPAL_ROLE:<my-principal-role>`)

### Polaris Variables (Optional, for Snowflake Open Data/Polaris integration)
- `polaris_client_id` (string, sensitive): Polaris Client ID
- `polaris_client_secret` (string, sensitive): Polaris Client Secret
- `polaris_account_name` (string): Polaris account name
- `polaris_username` (string): Polaris username
- `polaris_password` (string, sensitive): Polaris password
- `polaris_region` (string): Polaris region

### Databricks Variables (Optional, for Databricks integration)
- `databricks_workspace_id` (string): Databricks workspace ID
- `databricks_workspace_name` (string): Databricks workspace name
- `databricks_account_id` (string): Databricks account ID
- `databricks_host` (string): Databricks workspace host URL
- `databricks_token` (string, sensitive): Databricks workspace token

## Deployment Steps

1. Clone this repository and navigate to the project directory.
2. Define the required variables in a `variables.tf` file or a `.tfvars` file.
3. Run `terraform init` to initialize the Terraform project.
4. Run `terraform plan` to preview the changes.
5. Run `terraform apply` to provision the resources.

## Outputs

After deployment, the following outputs will be available:
- `kafka_api_key`: The Kafka API key.
- `kafka_api_secret`: The Kafka API secret (sensitive).
- `s3_access_role_arn`: The ARN of the S3 access role.
- `s3_bucket_name`: The name of the S3 bucket.

## Notes

- Ensure that your AWS and Confluent credentials are properly configured before running the scripts.
- The `prevent_destroy` lifecycle rule is set to `false` for API keys to allow re-creation if needed.
- Review the `depends_on` blocks to understand resource dependencies and avoid circular dependencies.
- This project supports integration with AWS Glue or Snowflake for downstream data processing.

For more details, refer to the individual `.tf` files in the project.
