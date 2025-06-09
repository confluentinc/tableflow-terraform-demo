resource "confluent_tableflow_topic" "stock_trades" {
  environment {
    id = confluent_environment.my_environment.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.kafka-cluster.id
  }
  display_name = confluent_kafka_topic.stock_trades.topic_name

  # Set table format based on catalog_type
  table_formats = var.catalog_type == "databricks" ? ["DELTA"] : ["ICEBERG"]

  // Use BYOB AWS storage
  byob_aws {
    bucket_name             = aws_s3_bucket.my_bucket.bucket
    provider_integration_id = confluent_provider_integration.main.id
  }

  credentials {
    key    = confluent_api_key.my-tableflow-api-key.id
    secret = confluent_api_key.my-tableflow-api-key.secret
  }

  # The goal is to ensure that confluent_schema.stock-trades is created before
  # an instance of confluent_tableflow_topic is created since it requires
  # a topic with a schema.
  depends_on = [
    aws_iam_role.s3_access_role,
    confluent_kafka_topic.stock_trades,
  ]
}