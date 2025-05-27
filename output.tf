# Outputs for tableflow-demo-with-glue module (optional)
output "glue_kafka_api_key" {
  value       = try(module.tableflow-demo-with-glue.kafka_api_key, null)
  description = "The Kafka API Key (Glue)"
}

output "glue_kafka_api_secret" {
  value       = try(module.tableflow-demo-with-glue.kafka_api_secret, null)
  description = "The Kafka API Secret (Glue)"
  sensitive   = true
}

output "glue_tableflow_api_key" {
  value       = try(module.tableflow-demo-with-glue.tableflow_api_key, null)
  description = "The Tableflow API Key (Glue)"
}

output "glue_tableflow_api_secret" {
  value       = try(module.tableflow-demo-with-glue.tableflow_api_secret, null)
  sensitive   = true
}

output "glue_environment_id" {
  value       = try(module.tableflow-demo-with-glue.environment_id, null)
  description = "The ID of the Confluent environment (Glue)"
}

output "glue_cluster_id" {
  value       = try(module.tableflow-demo-with-glue.cluster_id, null)
  description = "The ID of the Confluent Kafka cluster (Glue)"
}

output "glue_s3_access_role_arn" {
  value       = try(module.tableflow-demo-with-glue.s3_access_role_arn, null)
  description = "The ARN of the S3 access role (Glue)"
}

output "glue_s3_bucket_name" {
  value       = try(module.tableflow-demo-with-glue.s3_bucket_name, null)
  description = "The name of the S3 bucket (Glue)"
}

output "glue_stock_topic_id" {
  value       = try(module.tableflow-demo-with-glue.stock_topic_id, null)
  description = "The ID (UUID) of the Data Gen Stock Kafka Topic (Glue)"
}

# Outputs for tableflow-demo-with-snowflake module (optional)
output "snowflake_kafka_api_key" {
  value       = try(module.tableflow-demo-with-snowflake.kafka_api_key, null)
  description = "The Kafka API Key (Snowflake)"
}

output "snowflake_kafka_api_secret" {
  value       = try(module.tableflow-demo-with-snowflake.kafka_api_secret, null)
  description = "The Kafka API Secret (Snowflake)"
  sensitive   = true
}

output "snowflake_tableflow_api_key" {
  value       = try(module.tableflow-demo-with-snowflake.tableflow_api_key, null)
  description = "The Tableflow API Key (Snowflake)"
}

output "snowflake_tableflow_api_secret" {
  value       = try(module.tableflow-demo-with-snowflake.tableflow_api_secret, null)
  sensitive   = true
}

output "snowflake_environment_id" {
  value       = try(module.tableflow-demo-with-snowflake.environment_id, null)
  description = "The ID of the Confluent environment (Snowflake)"
}

output "snowflake_cluster_id" {
  value       = try(module.tableflow-demo-with-snowflake.cluster_id, null)
  description = "The ID of the Confluent Kafka cluster (Snowflake)"
}

output "snowflake_s3_access_role_arn" {
  value       = try(module.tableflow-demo-with-snowflake.s3_access_role_arn, null)
  description = "The ARN of the S3 access role (Snowflake)"
}

output "snowflake_s3_bucket_name" {
  value       = try(module.tableflow-demo-with-snowflake.s3_bucket_name, null)
  description = "The name of the S3 bucket (Snowflake)"
}

output "snowflake_stock_topic_id" {
  value       = try(module.tableflow-demo-with-snowflake.stock_topic_id, null)
  description = "The ID (UUID) of the Data Gen Stock Kafka Topic (Snowflake)"
}

# Outputs for tableflow-demo-with-databricks module (optional)
output "databricks_kafka_api_key" {
  value       = try(module.tableflow-demo-with-databricks.kafka_api_key, null)
  description = "The Kafka API Key (Databricks)"
}

output "databricks_kafka_api_secret" {
  value       = try(module.tableflow-demo-with-databricks.kafka_api_secret, null)
  description = "The Kafka API Secret (Databricks)"
  sensitive   = true
}

output "databricks_tableflow_api_key" {
  value       = try(module.tableflow-demo-with-databricks.tableflow_api_key, null)
  description = "The Tableflow API Key (Databricks)"
}

output "databricks_tableflow_api_secret" {
  value       = try(module.tableflow-demo-with-databricks.tableflow_api_secret, null)
  sensitive   = true
}

output "databricks_environment_id" {
  value       = try(module.tableflow-demo-with-databricks.environment_id, null)
  description = "The ID of the Confluent environment (Databricks)"
}

output "databricks_cluster_id" {
  value       = try(module.tableflow-demo-with-databricks.cluster_id, null)
  description = "The ID of the Confluent Kafka cluster (Databricks)"
}

output "databricks_s3_access_role_arn" {
  value       = try(module.tableflow-demo-with-databricks.s3_access_role_arn, null)
  description = "The ARN of the S3 access role (Databricks)"
}

output "databricks_s3_bucket_name" {
  value       = try(module.tableflow-demo-with-databricks.s3_bucket_name, null)
  description = "The name of the S3 bucket (Databricks)"
}

output "databricks_stock_topic_id" {
  value       = try(module.tableflow-demo-with-databricks.stock_topic_id, null)
  description = "The ID (UUID) of the Data Gen Stock Kafka Topic (Databricks)"
}
