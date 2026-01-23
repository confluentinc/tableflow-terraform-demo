output "bucket_name" {
  description = "The name of the S3 bucket created."
  value       = aws_s3_bucket.my_bucket.bucket
}