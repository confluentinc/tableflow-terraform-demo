# Retrieve information about the current user.
data "databricks_current_user" "me" {
    count = var.catalog_type == "databricks" ? 1 : 0
}


resource "databricks_storage_credential" "external" {
  count = var.catalog_type == "databricks" ? 1 : 0
  
  
  name = "databricks-external-role-${random_integer.suffix.result}"
  aws_iam_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.iam_role_name}"
  }
  comment = "Managed by TF"
  depends_on = [ aws_iam_role.s3_access_role, aws_iam_role_policy_attachment.s3_policy_attachment, aws_iam_role_policy.s3_access_role_self_assume_policy] 
}

resource "null_resource" "wait_for_iam_propagation" {
  count = var.catalog_type == "databricks" ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'Waiting for IAM propagation...' && sleep 60"
  }

  triggers = {
    iam_role = aws_iam_role.s3_access_role.id
    policy   = aws_iam_policy.s3_policy.id
    attach   = aws_iam_role_policy_attachment.s3_policy_attachment.id
  }
}

resource "databricks_external_location" "some" {
  count = var.catalog_type == "databricks" ? 1 : 0

  name            = "tableflow-ext-location-demo-${random_integer.suffix.result}"
  url             = "s3://${aws_s3_bucket.my_bucket.bucket}/"
  credential_name = databricks_storage_credential.external[0].id
  comment         = "Managed by TF"
  depends_on = [
    null_resource.wait_for_iam_propagation,
    aws_iam_role.s3_access_role,
    aws_iam_policy.s3_policy,
    aws_iam_role_policy_attachment.s3_policy_attachment,
    aws_iam_role_policy.s3_access_role_self_assume_policy,
    aws_s3_bucket.my_bucket,
    confluent_connector.stock_datagen,
    confluent_connector.users_datagen,
  ]
}


resource "databricks_grants" "some" {
  count = var.catalog_type == "databricks" ? 1 : 0


  provider = databricks.workspace
  external_location = databricks_external_location.some[0].id

  grant {
    principal  = data.databricks_current_user.current_principal_from_workspace_provider[0].user_name
    privileges = ["ALL_PRIVILEGES"]
  }
}


resource "databricks_directory" "shared_dir" {
  count = var.catalog_type == "databricks" ? 1 : 0
  path = "/Workspace/Users/${data.databricks_current_user.current_principal_from_workspace_provider[0].user_name}/Queries"
}

resource "databricks_query" "this" {
  count = var.catalog_type == "databricks" ? 1 : 0

  warehouse_id = data.databricks_sql_warehouse.my_existing_warehouse[0].id
  display_name = "My Query Name"
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