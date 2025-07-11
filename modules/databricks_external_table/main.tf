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
    depends_on = [  null_resource.wait_for_iam_propagation
]

}

resource "databricks_grants" "some" {

  # provider = databricks.workspace
  external_location = databricks_external_location.some.id

  grant {
    principal  = var.grant_principal
    privileges = ["ALL_PRIVILEGES"]
  }
  depends_on = [ databricks_external_location.some, databricks_storage_credential.external, null_resource.wait_for_iam_propagation ]
}

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