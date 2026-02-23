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

  # Azure Managed Identity configuration (preferred - uses Access Connector)
  dynamic "azure_managed_identity" {
    for_each = var.cloud_provider == "azure" && var.azure_access_connector_id != null ? [1] : []
    content {
      access_connector_id = var.azure_access_connector_id
    }
  }

  # Azure Service Principal configuration (fallback - used when access connector is not provided)
  dynamic "azure_service_principal" {
    for_each = var.cloud_provider == "azure" && var.azure_access_connector_id == null ? [1] : []
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


# Register the Azure AD service principal in the Databricks workspace
# This is required before the SP can be used as a grant principal
resource "databricks_service_principal" "tableflow_sp" {
  count            = var.cloud_provider == "azure" ? 1 : 0
  application_id   = var.databricks_sp_application_id
  display_name     = "tableflow-databricks-sp"
  active           = true
  workspace_access = true
  force            = true
}

# Generate a Databricks OAuth M2M secret for the service principal
# This is required for Confluent Tableflow catalog integration, which authenticates
# via Databricks OAuth (/oidc/v1/token) rather than Azure AD tokens
resource "databricks_service_principal_secret" "tableflow_oauth" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  service_principal_id = databricks_service_principal.tableflow_sp[0].id
}

resource "databricks_catalog" "unity-demo-catalog" {
  name           = "unity-demo-${var.random_suffix}"
  comment        = "Managed by TF"
  properties     = {}
  force_destroy  = true
  isolation_mode = "OPEN"

  # Use the external location as managed storage since the metastore may not have a default storage root
  storage_root = var.cloud_provider == "aws" ? "s3://${var.storage_location_name}/catalog" : "abfss://${var.container_name}@${var.storage_account_name}.dfs.core.windows.net/catalog"

  depends_on = [databricks_external_location.some]
}
resource "databricks_grants" "grant_service_principal" {

  external_location = databricks_external_location.some.id

  dynamic "grant" {
    for_each = var.grant_principals
    content {
      principal  = grant.value
      privileges = ["ALL_PRIVILEGES", "MANAGE", "EXTERNAL_USE_LOCATION", "CREATE_EXTERNAL_TABLE", "READ_FILES", "WRITE_FILES"]
    }
  }
  grant {
    principal  = data.databricks_current_user.me.user_name
    privileges = ["ALL_PRIVILEGES", "MANAGE", "EXTERNAL_USE_LOCATION", "CREATE_EXTERNAL_TABLE", "READ_FILES", "WRITE_FILES"]
  }
  grant {
    principal  = "account users"
    privileges = ["ALL_PRIVILEGES", "EXTERNAL_USE_LOCATION", "MANAGE"]
  }

  depends_on = [databricks_external_location.some, databricks_storage_credential.external, time_sleep.wait_for_iam_propagation, databricks_service_principal.tableflow_sp]
}

resource "databricks_grants" "grant_storage_credential" {
  storage_credential = databricks_storage_credential.external.id

  dynamic "grant" {
    for_each = var.grant_principals
    content {
      principal  = grant.value
      privileges = ["ALL_PRIVILEGES", "MANAGE"]
    }
  }
  grant {
    principal  = data.databricks_current_user.me.user_name
    privileges = ["ALL_PRIVILEGES", "MANAGE"]
  }

  depends_on = [databricks_storage_credential.external, databricks_service_principal.tableflow_sp]
}

resource "databricks_grants" "current_user_use_schema" {

  catalog = databricks_catalog.unity-demo-catalog.name

  dynamic "grant" {
    for_each = var.grant_principals
    content {
      principal  = grant.value
      privileges = ["ALL_PRIVILEGES", "EXTERNAL_USE_SCHEMA", "MANAGE", "CREATE_SCHEMA", "CREATE_TABLE", "SELECT", "USE_CATALOG", "USE_SCHEMA"]
    }
  }
  grant {
    principal  = data.databricks_current_user.me.user_name
    privileges = ["ALL_PRIVILEGES", "EXTERNAL_USE_SCHEMA", "MANAGE", "CREATE_SCHEMA", "CREATE_TABLE", "SELECT", "USE_CATALOG", "USE_SCHEMA"]
  }
  grant {
    principal  = "account users"
    privileges = ["ALL_PRIVILEGES", "BROWSE", "EXTERNAL_USE_SCHEMA", "MANAGE"]
  }
  depends_on = [databricks_storage_credential.external, time_sleep.wait_for_iam_propagation, databricks_service_principal.tableflow_sp]
}






resource "databricks_directory" "shared_dir" {
  path             = var.shared_dir_path
  delete_recursive = true
}

# Wait for SQL warehouse to start up before executing queries
# SQL warehouses are created in STOPPED state and need time to start
resource "time_sleep" "wait_for_warehouse_startup" {
  create_duration = "60s"

  # This ensures we only wait when using a warehouse (not null)
  triggers = {
    warehouse_id = var.sql_warehouse_id
  }
}

resource "databricks_query" "this" {
  warehouse_id = var.sql_warehouse_id
  display_name = var.query_display_name
  parent_path  = databricks_directory.shared_dir.path

  depends_on = [time_sleep.wait_for_warehouse_startup]

  query_text = <<-EOT
      DROP TABLE IF EXISTS ${databricks_catalog.unity-demo-catalog.name}.default.ext_stockquotes;

      -- This query creates an external table in the Databricks Unity Catalog
      CREATE TABLE IF NOT EXISTS ${databricks_catalog.unity-demo-catalog.name}.default.ext_stockquotes
       USING DELTA
      LOCATION '${var.cloud_provider == "aws" ? "s3://${var.storage_location_name}" : "abfss://${var.container_name}@${var.storage_account_name}.dfs.core.windows.net"}/10110100/110101/${var.confluent_organization_id}/${var.confluent_environment_id}/${var.confluent_cluster_id}/v1/${var.kafka_topic_id}/';

    SELECT * FROM ${databricks_catalog.unity-demo-catalog.name}.default.ext_stockquotes LIMIT 100;
  EOT
}