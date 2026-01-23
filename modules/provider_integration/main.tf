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
  # CRITICAL LIMITATION: As of Confluent provider v2.58.0, Azure BYOB is NOT supported
  # in the Terraform provider. The 'azure' block does not exist in confluent_provider_integration.
  #
  # Azure support must be configured manually through:
  # 1. Confluent Cloud UI
  # 2. Confluent Cloud REST API
  # 3. Wait for future Confluent provider version that adds Azure support
  #
  # Commenting out until Azure is supported in the Confluent Terraform provider:
  #
  # dynamic "azure" {
  #   for_each = var.cloud_provider == "azure" ? [1] : []
  #   content {
  #     tenant_id            = var.azure_tenant_id
  #     application_id       = var.azure_application_id
  #     application_secret   = var.azure_application_secret
  #     storage_account_name = var.azure_storage_account_name
  #   }
  # }

  # Validation: Fail if Azure is selected (not supported yet)
  lifecycle {
    precondition {
      condition     = var.cloud_provider != "azure"
      error_message = "Azure BYOB is not yet supported in Confluent Terraform provider v2.58.0. Please use AWS or wait for Azure support to be added to the provider."
    }
  }
}
