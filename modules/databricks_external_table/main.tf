terraform {
  required_providers {
  databricks = {
    source  = "databricks/databricks"
      version = ">= 1.0.0"
  }
}
}


data "databricks_current_user" "me" {
}



resource "databricks_storage_credential" "external" {
  name = var.storage_credential_name
  aws_iam_role {
    role_arn = var.aws_iam_role_arn
  }
  comment = "Managed by TF"
}

resource "null_resource" "wait_for_iam_propagation" {

  provisioner "local-exec" {
    command = "echo 'Waiting for IAM propagation...' && sleep 60"
  }

  triggers = {
    iam_role = var.iam_role_id
    policy   = var.iam_policy_id
    attach   = var.iam_policy_attachment_id
  }
}

resource "databricks_external_location" "some" {

  name            = var.external_location_name
  url             = "s3://${var.s3_bucket_name}/"
  credential_name = databricks_storage_credential.external.id
  comment         = "Managed by TF"
    depends_on = [  null_resource.wait_for_iam_propagation]
  force_destroy = true

}


resource "databricks_catalog" "unity-demo-catalog" {
  name        = "unity-demo-${var.random_suffix}"
  comment     = "Managed by TF"
  properties  = {}
  force_destroy = true
  depends_on  = [databricks_storage_credential.external, null_resource.wait_for_iam_propagation]
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

  depends_on = [ databricks_external_location.some, databricks_storage_credential.external, null_resource.wait_for_iam_propagation ]
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
  depends_on = [ databricks_storage_credential.external, null_resource.wait_for_iam_propagation ]
}

# resource "databricks_grants" "current_user_manage_tables" {

#   schema = "${data.databricks_catalog.tableflow_delta.name}.${var.confluent_cluster_id}"

#   grant {
#     principal  = data.databricks_current_user.me.user_name
#   privileges = ["MANAGE"]
#   }
#   depends_on = [ databricks_storage_credential.external, null_resource.wait_for_iam_propagation ]
# }






resource "databricks_directory" "shared_dir" {
  path = var.shared_dir_path
}

resource "databricks_query" "this" {

  warehouse_id = var.sql_warehouse_id
  display_name = var.query_display_name
  parent_path  = databricks_directory.shared_dir.path

  query_text = <<-EOT
      DROP TABLE tableflowdelta.default.ext_stockquotes;

      -- This query creates an external table in the Databricks Unity Catalog
      CREATE TABLE IF NOT EXISTS tableflowdelta.default.ext_stockquotes
       USING DELTA
      LOCATION 's3://${var.s3_bucket_name}/10110100/110101/${var.confluent_organization_id}/${var.confluent_environment_id}/${var.confluent_cluster_id}/v1/${var.kafka_topic_id}/';

    SELECT * FROM tableflowdelta.default.ext_stockquotes LIMIT 100;
  EOT
}