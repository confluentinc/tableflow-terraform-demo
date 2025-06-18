output "kafka_api_key" {
  value       = confluent_api_key.kafka-api-key.id
  description = "The Kafka API Key"
}

output "kafka_api_secret" {
  value       = confluent_api_key.kafka-api-key.secret
  description = "The Kafka API Secret"
  sensitive   = true
}


output "tableflow_api_key" {
  value = confluent_api_key.my-tableflow-api-key.id
  description = "The Tableflow API Key"
  }

output "tableflow_api_secret" {
  value = confluent_api_key.my-tableflow-api-key.secret
  sensitive = true
}

output "environment_id" {
  value       = confluent_environment.my_environment.id
  description = "The ID of the Confluent environment"
}

output "cluster_id" {
  value       = confluent_kafka_cluster.kafka-cluster.id
  description = "The ID of the Confluent Kafka cluster"
}

output "s3_access_role_arn" {
  value       = aws_iam_role.s3_access_role.arn
  description = "The ARN of the S3 access role"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.my_bucket.bucket
  description = "The name of the S3 bucket"
}

output "stock_topic_id" {
  description = "The ID (UUID) of the Data Gen Stock Kafka Topic."
  value       = confluent_kafka_topic.stock_trades.id
}



