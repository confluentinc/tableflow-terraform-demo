variable "provider_name" {
  description = "The provider name to append to the S3 bucket name (e.g., glue, snowflake, databricks)."
  type        = string
}

variable "bucket_suffix" {
  description = "A random integer suffix to ensure bucket name uniqueness."
  type        = string
}