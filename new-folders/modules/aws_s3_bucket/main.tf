terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.17.0"
    }
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "cflt-tflow-${var.provider_name}-${var.bucket_suffix}"

  tags = {
    Name = "cflt-tflow-${var.provider_name}-${var.bucket_suffix}"
  }
  force_destroy = true
}

