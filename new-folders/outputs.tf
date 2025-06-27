# outputs.tf

output "confluent_environment_id" {
  description = "The ID of the Confluent Cloud environment."
  value       = confluent_environment.my_environment.id
}

output "kafka_clusters_info" {
  description = "Information about the created Kafka clusters."
  value = {
    for k, v in confluent_kafka_cluster.clusters : k => {
      id           = v.id
      name         = v.display_name
      cloud        = v.cloud
      region       = v.region
      rest_endpoint = v.rest_endpoint
    }
  }
}