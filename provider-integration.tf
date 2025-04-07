resource "confluent_provider_integration" "main" {
  display_name = "s3_tableflow_integration"
  environment {
    id = confluent_environment.my_environment.id
  }
  aws {
    # During the creation of confluent_provider_integration.main, the S3 role does not yet exist.
    # The role will be created after confluent_provider_integration.main is provisioned
    # by the s3_access_role module using the specified target name.
    # Note: This is a workaround to avoid updating an existing role or creating a circular dependency.
    customer_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.iam_role_name}"
  }
}
