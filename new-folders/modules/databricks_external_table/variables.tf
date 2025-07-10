variable "storage_credential_name" {
  description = "The name for the Databricks storage credential."
  type        = string
}

variable "aws_iam_role_arn" {
  description = "The ARN of the AWS IAM role to use for Databricks."
  type        = string
}

variable "iam_role_id" {
  description = "The ID of the IAM role."
  type        = string
}

variable "iam_policy_id" {
  description = "The ID of the IAM policy."
  type        = string
}

variable "iam_policy_attachment_id" {
  description = "The ID of the IAM policy attachment."
  type        = string
}

variable "external_location_name" {
  description = "The name for the Databricks external location."
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "catalog_type" {
  description = "The catalog type (should be 'databricks' for this module)."
  type        = string
}

variable "grant_principal" {
  description = "The principal to grant privileges to."
  type        = string
}

variable "shared_dir_path" {
  description = "The path for the shared directory in Databricks."
  type        = string
}

variable "sql_warehouse_id" {
  description = "The ID of the Databricks SQL warehouse."
  type        = string
}

variable "query_display_name" {
  description = "The display name for the Databricks query."
  type        = string
}