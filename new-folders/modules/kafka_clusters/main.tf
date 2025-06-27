terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent" 
      version = "2.22.0"                
    }
  }
  }

resource "confluent_kafka_cluster" "my_cluster" {
  display_name = var.cluster_name
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.aws_region
  standard {}

  environment {
    id = var.environment_id
  }

  lifecycle {
    prevent_destroy = false
  }
}
