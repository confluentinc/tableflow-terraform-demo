terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.32.0"
    }
  }
}

# AWS Provider Integration (single resource pattern)
resource "confluent_provider_integration" "aws" {
  count = var.cloud_provider == "aws" ? 1 : 0

  display_name = "${var.cloud_provider}_tableflow_integration_${var.provider_name}"
  environment {
    id = var.environment_id
  }

  # During the creation of confluent_provider_integration, the IAM role does not yet exist.
  # The role will be created after confluent_provider_integration is provisioned
  # by the s3_access_role module using the specified target name.
  aws {
    customer_role_arn = var.customer_role_arn
  }
}

# Azure Provider Integration (two-step pattern)
# Step 1: Setup the provider integration
resource "confluent_provider_integration_setup" "azure" {
  count = var.cloud_provider == "azure" ? 1 : 0

  display_name = "${var.cloud_provider}_tableflow_integration_${var.provider_name}"
  environment {
    id = var.environment_id
  }

  cloud = "AZURE"
}

# Step 2: Authorize the provider integration with Azure tenant
resource "confluent_provider_integration_authorization" "azure" {
  count = var.cloud_provider == "azure" ? 1 : 0

  provider_integration_id = confluent_provider_integration_setup.azure[0].id

  environment {
    id = var.environment_id
  }

  azure {
    customer_azure_tenant_id = var.azure_tenant_id
  }
}

# GCP Provider Integration (placeholder for future implementation)
# GCP follows the same two-step pattern as Azure
