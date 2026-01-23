terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

resource "confluent_provider_integration" "main" {
  display_name = "${var.cloud_provider}_tableflow_integration_${var.provider_name}"
  environment {
    id = var.environment_id
  }

  # AWS Provider Integration
  # During the creation of confluent_provider_integration.main, the IAM role does not yet exist.
  # The role will be created after confluent_provider_integration.main is provisioned
  # by the s3_access_role module using the specified target name.
  dynamic "aws" {
    for_each = var.cloud_provider == "aws" ? [1] : []
    content {
      customer_role_arn = var.customer_role_arn
    }
  }

  # Azure Provider Integration
  dynamic "azure" {
    for_each = var.cloud_provider == "azure" ? [1] : []
    content {
      tenant_id            = var.azure_tenant_id
      application_id       = var.azure_application_id
      application_secret   = var.azure_application_secret
      storage_account_name = var.azure_storage_account_name
    }
  }
}
