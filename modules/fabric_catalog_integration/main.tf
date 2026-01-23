# Microsoft Fabric Catalog Integration for Tableflow
#
# CRITICAL LIMITATION: As of Confluent Terraform Provider v2.58.0, Microsoft Fabric
# is NOT supported. The confluent_catalog_integration resource only supports:
# - aws_glue
# - snowflake
#
# This module is a PLACEHOLDER for future Fabric support. See AZURE_LIMITATION.md.

terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# Placeholder resource that does nothing but provides a module structure
# ready for when Fabric support is added to the Confluent provider
resource "null_resource" "fabric_not_supported_notice" {
  provisioner "local-exec" {
    command = "echo 'WARNING: Microsoft Fabric catalog integration is not supported in Confluent Terraform provider v2.58.0. See AZURE_LIMITATION.md for manual setup instructions.'"
  }

  triggers = {
    environment_id = var.environment_id
    cluster_id     = var.cluster_id
  }
}

# Future implementation (when Confluent provider adds Fabric support):
#
# resource "confluent_catalog_integration" "fabric" {
#   display_name = "fabric_catalog_integration"
#   environment {
#     id = var.environment_id
#   }
#   kafka_cluster {
#     id = var.cluster_id
#   }
#   fabric {
#     workspace_id = var.fabric_workspace_id
#     tenant_id    = var.azure_tenant_id
#   }
#   credentials {
#     key    = var.tableflow_api_key
#     secret = var.tableflow_api_secret
#   }
# }
