# outputs.tf
output "confluent_environment_id" {
  description = "The ID of the Confluent Cloud environment."
  value       = module.confluent_env_module.environment_id
}

output "kafka_cluster_ids" {
  description = "A map of all Kafka cluster IDs, keyed by cluster name."
  value       = { for k, m in module.kafka_clusters : k => m.cluster_id }
}

output "iam_role_names" {
  description = "A map of all IAM role names created, keyed by cluster name."
  value       = { for k, m in module.aws_iam_role : k => m.role_name }
}

output "s3_bucket_names" {
  description = "A map of all S3 bucket names created, keyed by cluster name."
  value       = { for k, m in module.aws_s3_bucket : k => m.bucket_name }
}
