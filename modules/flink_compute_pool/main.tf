terraform {
    required_providers {
  confluent = {
    source  = "confluentinc/confluent"
    version = ">= 2.32.0"
  }
}
}


resource "confluent_flink_compute_pool" "my_compute_pool" {
  display_name     = var.display_name
  cloud            = var.cloud
  region           = var.region
  max_cfu          = var.max_cfu
  environment {
    id = var.environment_id
  }
}