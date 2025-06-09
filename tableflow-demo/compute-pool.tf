resource "confluent_flink_compute_pool" "my_compute_pool" {
  display_name     = "flink_compute_pool"
  cloud            = "AWS"
  region           = var.aws_region
  max_cfu          = 5
  environment {
    id = confluent_environment.my_environment.id
  }
}