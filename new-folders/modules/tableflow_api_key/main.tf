terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

# Tableflow API Keys
resource "confluent_api_key" "my-tableflow-api-key" {
  display_name = "app-manager-tableflow-api-key"
  description  = "Tableflow API Key that is owned by 'app-manager' service account"
  owner {
    id          = var.service_account_id
    api_version = var.service_account_api_version
    kind        = var.service_account_kind
  }

  managed_resource {
    id          = "tableflow"
    api_version = "tableflow/v1"
    kind        = "Tableflow"


    environment {
      id = var.environment_id
    }
  }
}
