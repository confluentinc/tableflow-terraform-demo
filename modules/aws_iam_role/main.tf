terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.17.0"
    }
  }
}

resource "aws_iam_role" "s3_access_role" {
  name        = var.customer_role_name
  description = "IAM role for accessing S3 with a trust policy for Confluent Tableflow"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = flatten(concat( 
      [
        {
          Effect    = "Allow"
          Principal = {
            AWS = var.provider_integration_role_arn
          }
          Action    = "sts:AssumeRole"
          Condition = {
            StringEquals = {
              "sts:ExternalId" = var.provider_integration_external_id
            }
          }
        },
        {
          Effect    = "Allow"
          Principal = {
            AWS = var.provider_integration_role_arn
          }
          Action    = "sts:TagSession"
        }
      ],
      [
        for val in (var.provider_type == "databricks" ? [true] : []) : [ 
          { 
            Effect    = "Allow"
            Action    = "sts:AssumeRole"
            Principal = {
              AWS = "arn:aws:iam::414351767826:root"
            }
            Condition = {
              StringEquals = {
                "sts:ExternalId" = var.databricks_account_id
              }
            }
          },
          { 
            Effect    = "Allow"
            Action    = "sts:AssumeRole"
            Principal = {
              AWS = [
                "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL",
                "arn:aws:iam::${var.aws_account_id}:root"
              ]
            }
            Condition = {
              StringEquals = {
                "sts:ExternalId" = var.databricks_account_id
              }
              ArnEquals = {
                "aws:PrincipalArn" = "arn:aws:iam::${var.aws_account_id}:role/${var.customer_role_name}"
              }
            }
          }
        ] 
      ]
    ))
  })
}

# https://docs.confluent.io/cloud/current/connectors/cc-s3-sink/cc-s3-sink.html#user-account-iam-policy
resource "aws_iam_policy" "s3_access_policy" {
  name        = "TableflowS3AccessPolicy-${var.provider_type}-${var.random_suffix}"
  description = "IAM policy for accessing the S3 bucket for Confluent Tableflow"

  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*",
          "arn:aws:s3:::${var.s3_bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_role_self_assume_policy" {
  count       = var.provider_type == "databricks" ? 1 : 0
  name        = "TableflowS3AccessPolicy-${var.provider_type}-${var.random_suffix}-self-assume"
  description = "IAM policy for the role to assume itself for Databricks Unity Catalog"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.s3_access_role.arn
      }
    ]
  })
}

# Attach the primary S3 access policy
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# NEW: Attach the self-assume managed policy
resource "aws_iam_role_policy_attachment" "self_assume_policy_attachment" {
  count      = var.provider_type == "databricks" ? 1 : 0
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_role_self_assume_policy[count.index].arn
}


resource "aws_iam_role_policy_attachment" "attach_glue_access" {
  count      = var.provider_type == "glue" ? 1 : 0
  role       = aws_iam_role.s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}
