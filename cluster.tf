resource "confluent_kafka_cluster" "kafka-cluster" {
  display_name = "My Kafka Cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.aws_region
  standard {}

  environment {
    id = confluent_environment.my_environment.id
  }

  lifecycle {
    prevent_destroy = false
  }
}
