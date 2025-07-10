
data "databricks_current_user" "me" {}

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
  credential_name = databricks_storage_credential.external[0].id
  comment         = "Managed by TF"

}

resource "databricks_grants" "some" {

  provider = databricks.workspace
  external_location = databricks_external_location.some[0].id

  grant {
    principal  = var.grant_principal
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_directory" "shared_dir" {
  path = var.shared_dir_path
}

resource "databricks_query" "this" {

  warehouse_id = var.sql_warehouse_id
  display_name = var.query_display_name
  parent_path  = databricks_directory.shared_dir[0].path

  query_text = <<-EOT
      DROP TABLE tableflowdelta.default.ext_stockquotes;

      -- This query creates an external table in the Databricks Unity Catalog
      CREATE TABLE IF NOT EXISTS tableflowdelta.default.ext_stockquotes
       USING DELTA
       LOCATION 's3://jber-confluent-databricks-data/10110100/110101/79ee1009-b72b-4016-88bd-b18ca2b5067d/env-7k7dg1/lkc-7977pj/v1/949eff0f-70d9-47f7-9315-d1f595373d5e/';

    SELECT * FROM tableflowdelta.default.ext_stockquotes LIMIT 100;
  EOT
}