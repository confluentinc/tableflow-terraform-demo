terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}


data "confluent_schema_registry_cluster" "essentials" { 
  environment {
    id = var.environment_id
  }
}

resource "confluent_api_key" "my-schema-registry-api-key" {
  display_name = "my-schema-registry-api-key"
  description  = "Schema Registry API Key that is owned by 'my_service_account' service account"
  owner {
    id          = var.service_account_id
    api_version = var.service_account_api_version
    kind        = var.service_account_kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.essentials.id
    api_version = data.confluent_schema_registry_cluster.essentials.api_version
    kind        = data.confluent_schema_registry_cluster.essentials.kind

    environment {
      id = var.environment_id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}