output "topic_name" {
  description = "The name of the Kafka topic created."
  value       = confluent_kafka_topic.kafka_topic.topic_name
}

output "topic_id" {
  description = "The ID of the Kafka topic created."
  value       = confluent_kafka_topic.kafka_topic.id
}