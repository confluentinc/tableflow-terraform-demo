locals {
    iam_role_name = "tableflow-role-${random_integer.suffix.result}"
}


resource "aws_iam_policy" "s3_policy" {
    name        = "TableflowS3AccessPolicy"
    description = "Policy to allow S3 bucket access"
    policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetBucketLocation",
                    "s3:ListBucketMultipartUploads",
                    "s3:ListBucket"
                ]
                Resource = [
                    "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "s3:PutObject",
                    "s3:PutObjectTagging",
                    "s3:GetObject",
                    "s3:DeleteObject",
                    "s3:AbortMultipartUpload",
                    "s3:ListMultipartUploadParts"
                ]
                Resource = [
                    "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}/*"
                ]
            }
        ]
    })
}

# https://docs.confluent.io/cloud/current/connectors/provider-integration/index.html
resource "aws_iam_role" "s3_access_role" {
  name        = local.iam_role_name
  description = "IAM role for accessing S3 with a trust policy for Confluent Tableflow"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = confluent_provider_integration.main.aws[0].iam_role_arn
        }
        Action    = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = confluent_provider_integration.main.aws[0].external_id
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = {
          AWS = confluent_provider_integration.main.aws[0].iam_role_arn
        }
        Action    = "sts:TagSession"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
    role       = aws_iam_role.s3_access_role.name
    policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_glue_access" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}


