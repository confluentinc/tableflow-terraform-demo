terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent" 
      version = "2.22.0"                
    }
  }
  }


resource "confluent_environment" "my_environment" {
  display_name = var.environment_name

  stream_governance {
    package = "ESSENTIALS"
  }

  lifecycle {
    prevent_destroy = false
  }
}
