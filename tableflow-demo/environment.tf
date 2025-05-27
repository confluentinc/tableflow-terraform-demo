resource "confluent_environment" "my_environment" {
  display_name = var.environment_display_name

  stream_governance {
    package = "ESSENTIALS"
  }

  lifecycle {
    prevent_destroy = false
  }
}