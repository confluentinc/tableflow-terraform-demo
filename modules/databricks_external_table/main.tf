terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}


data "databricks_current_user" "me" {
}



resource "databricks_storage_credential" "external" {
  name = var.storage_credential_name

  # AWS IAM Role configuration
  dynamic "aws_iam_role" {
    for_each = var.cloud_provider == "aws" ? [1] : []
    content {
      role_arn = var.aws_iam_role_arn
    }
  }

  # Azure Service Principal configuration
  dynamic "azure_service_principal" {
    for_each = var.cloud_provider == "azure" ? [1] : []
    content {
      directory_id   = var.azure_tenant_id
      application_id = var.azure_application_id
      client_secret  = var.azure_client_secret
    }
  }

  comment = "Managed by TF"
}

# Wait for IAM role and policy propagation across AWS regions
# IAM changes typically propagate in 10-20 seconds, using 30s for safety margin
resource "time_sleep" "wait_for_iam_propagation" {
  create_duration = "30s"

  triggers = {
    iam_role = var.iam_role_id
    policy   = var.iam_policy_id
    attach   = var.iam_policy_attachment_id
  }

  depends_on = [var.iam_role_id, var.iam_policy_id, var.iam_policy_attachment_id]
}

resource "databricks_external_location" "some" {
  name = var.external_location_name

  # Dynamic URL based on cloud provider
  # AWS: s3://bucket-name/
  # Azure: abfss://container-name@storage-account-name.dfs.core.windows.net/
  url = var.cloud_provider == "aws" ? "s3://${var.storage_location_name}/" : "abfss://${var.container_name}@${var.storage_account_name}.dfs.core.windows.net/"

  credential_name = databricks_storage_credential.external.id
  comment         = "Managed by TF"
  depends_on      = [time_sleep.wait_for_iam_propagation]
  force_destroy   = true
}


resource "databricks_catalog" "unity-demo-catalog" {
  name          = "unity-demo-${var.random_suffix}"
  comment       = "Managed by TF"
  properties    = {}
  force_destroy = true
  depends_on    = [databricks_storage_credential.external]
}
resource "databricks_grants" "grant_service_principal" {

  external_location = databricks_external_location.some.id

  grant {
    principal  = var.grant_principal
    privileges = ["CREATE EXTERNAL TABLE", "READ FILES", "WRITE FILES"]
  }
  grant {
    principal  = data.databricks_current_user.me.user_name
    privileges = ["CREATE EXTERNAL TABLE", "READ FILES", "WRITE FILES"]
  }

  depends_on = [databricks_external_location.some, databricks_storage_credential.external, time_sleep.wait_for_iam_propagation]
}

resource "databricks_grants" "current_user_use_schema" {

  catalog = databricks_catalog.unity-demo-catalog.name

  grant {
    principal  = var.grant_principal
    privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT", "MANAGE"]
  }
  grant {
    principal  = data.databricks_current_user.me.user_name
    privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT", "MANAGE"]
  }
  depends_on = [databricks_storage_credential.external, time_sleep.wait_for_iam_propagation]
}






resource "databricks_directory" "shared_dir" {
  path = var.shared_dir_path
}

resource "databricks_query" "this" {
  warehouse_id = var.sql_warehouse_id
  display_name = var.query_display_name
  parent_path  = databricks_directory.shared_dir.path

  query_text = <<-EOT
      DROP TABLE IF EXISTS ${databricks_catalog.unity-demo-catalog.name}.default.ext_stockquotes;

      -- This query creates an external table in the Databricks Unity Catalog
      CREATE TABLE IF NOT EXISTS ${databricks_catalog.unity-demo-catalog.name}.default.ext_stockquotes
       USING DELTA
      LOCATION '${var.cloud_provider == "aws" ? "s3://${var.storage_location_name}" : "abfss://${var.container_name}@${var.storage_account_name}.dfs.core.windows.net"}/10110100/110101/${var.confluent_organization_id}/${var.confluent_environment_id}/${var.confluent_cluster_id}/v1/${var.kafka_topic_id}/';

    SELECT * FROM ${databricks_catalog.unity-demo-catalog.name}.default.ext_stockquotes LIMIT 100;
  EOT
}