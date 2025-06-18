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
    principal  = "account users"
    privileges = ["ALL_PRIVILEGES"]
  }
}


resource "databricks_directory" "shared_dir" {
  count = var.catalog_type == "databricks" ? 1 : 0
  path = "/Workspace/Users/${data.databricks_current_user.current_principal_from_workspace_provider[0].user_name}/Queries"
}

# resource "databricks_sql_table" "external_stockquotes" {
#   count = var.catalog_type == "databricks" ? 1 : 0

#   name = "ext_stockquotes-${random_integer.suffix.result}"
#   catalog_name = "workspace"
#   schema_name = "default"
#   table_type = "EXTERNAL"
#   # cluster_id = "0610-163144-bza1agxk"

#   storage_location = "s3://cflt-tflow-4955/1101100/110101/79ee1009-b72b-4016-88bd-b18ca2b5067d/env-pw8jgm/lkc-rx076k/v1/e9a8cb68-7670-410e-9c26-dd954ffa4ab6"

#   depends_on = [
#     databricks_external_location.some,
#     databricks_storage_credential.external
#   ]
#   comment = "External table for stock quotes data managed by Tableflow"
# }


