
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

resource "confluent_catalog_integration" "my_catalog" {
  count = var.catalog_type == "glue" ? 1 : 0
  environment {
    id = var.environment_id
  }
  kafka_cluster {
    id = var.cluster_id
  }
  display_name = "catalog-integration-1"
  aws_glue {
    provider_integration_id = var.provider_integration_internal_id
  }
  credentials {
    key    = var.tableflow_api_key
    secret = var.tableflow_api_secret
  }

  lifecycle {
    prevent_destroy = false
  }
}
