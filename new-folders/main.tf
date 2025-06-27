# One Confluent environment to rule them all
resource "confluent_environment" "my_environment" {
  display_name = var.environment_display_name

  stream_governance {
    package = "ESSENTIALS"
  }

  lifecycle {
    prevent_destroy = false
  }
}


# Create three Kafka clusters based on the 'catalog_types' list
# The 'for_each' meta-argument requires a map or a set of strings.
resource "confluent_kafka_cluster" "clusters" {
  for_each = { for ct in var.catalog_types : ct => ct }

  display_name = "kafka-${each.value}"
  availability = "SINGLE_ZONE" 
  cloud        = "AWS"
  region       = var.aws_region

  environment {
    id = confluent_environment.my_environment.id
  }
  standard {} 
}


# TODO: Create a Confluent Schema Registry for each Kafka cluster