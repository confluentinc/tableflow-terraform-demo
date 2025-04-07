terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.22.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.17.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "confluent_organization" "current" {}


