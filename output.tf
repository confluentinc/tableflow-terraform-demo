output "kafka_api_key" {
  value       = confluent_api_key.kafka-api-key.id
  description = "The Kafka API Key"
}

output "kafka_api_secret" {
  value       = confluent_api_key.kafka-api-key.secret
  description = "The Kafka API Secret"
  sensitive   = true
}

output "s3_access_role_arn" {
  value       = aws_iam_role.s3_access_role.arn
  description = "The ARN of the S3 access role"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.my_bucket.bucket
  description = "The name of the S3 bucket"
}