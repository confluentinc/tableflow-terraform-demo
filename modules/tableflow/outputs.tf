output "tableflow_topic_id" {
  description = "The ID of the Tableflow topic."
  value       = confluent_tableflow_topic.this.id
}

output "tableflow_topic_name" {
  description = "The display name of the Tableflow topic."
  value       = confluent_tableflow_topic.this.display_name
}

output "tableflow_topic_status" {
  description = "The status of the Tableflow topic."
  value       = confluent_tableflow_topic.this.suspended
}