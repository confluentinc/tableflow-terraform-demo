# Tableflow Project

This project contains Terraform scripts to provision and configure resources for a data pipeline using AWS and Confluent Cloud. The pipeline integrates Kafka topics, IAM roles, S3 storage, and Confluent Tableflow for managing data streams and schemas. **This project is designed for demonstration purposes and supports integration with AWS Glue or Snowflake for downstream data processing.**

## Overview

The Terraform scripts in this project perform the following tasks:
- Create Kafka topics (`stock_trades` and `users`) in Confluent Cloud.
- Configure a Datagen Source Connector to generate sample data for the `stock_trades` and `users` topics.
- Set up an S3 bucket and IAM roles/policies for BYOB (Bring Your Own Bucket) integration with Confluent Tableflow.
- Provision a Confluent Tableflow topic (`stock_trades`) with Iceberg table format.
- Manage API keys for Kafka and Tableflow access.

## Prerequisites

Before using these scripts, ensure you have:
1. **AWS Account**: Required for S3 bucket and IAM role creation.
2. **Confluent Cloud Account**: Required for Kafka, Tableflow, and connector provisioning.

## Required Variables

You need to define the following variables in a `variables.tf` file or provide them via environment variables or a `.tfvars` file:

- **AWS Variables**:
  - `aws_region`: The AWS region where resources will be created.
  - `bucket_name`: The name of the S3 bucket for BYOB integration.

- **Confluent Variables**:
  - `confluent_environment_id`: The ID of the Confluent environment.
  - `kafka_cluster_id`: The ID of the Kafka cluster.
  - `service_account_id`: The ID of the Confluent service account.
  - `schema_registry_cluster_id`: The ID of the Schema Registry cluster.

- **Other Variables**:
  - `iam_role_name`: The name of the IAM role for S3 access.
  - `tableflow_display_name`: The display name for the Tableflow topic.

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
