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

resource "databricks_external_location" "some" {
  count = var.catalog_type == "databricks" ? 1 : 0

  name            = "tableflow-ext-location-demo-${random_integer.suffix.result}"
  url             = "s3://${aws_s3_bucket.my_bucket.bucket}/"
  credential_name = databricks_storage_credential.external[0].id
  comment         = "Managed by TF"
  depends_on = [ aws_iam_role.s3_access_role, aws_iam_role_policy_attachment.s3_policy_attachment, aws_iam_role_policy.s3_access_role_self_assume_policy, aws_iam_policy.s3_policy]
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