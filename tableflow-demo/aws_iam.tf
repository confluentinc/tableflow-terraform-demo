locals {
    iam_role_name = "tableflow-role-${random_integer.suffix.result}"
}

# --- Existing S3 Access Policy ---
resource "aws_iam_policy" "s3_policy" {
  name        = "TableflowS3AccessPolicy-${aws_s3_bucket.my_bucket.id}"
  description = "Policy to allow S3 bucket access"
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
          "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}/*",
          "arn:aws:s3:::${aws_s3_bucket.my_bucket.id}"
        ]
      }
    ]
  })
}

# --- IAM Role Definition ---
# https://docs.confluent.io/cloud/current/connectors/provider-integration/index.html
resource "aws_iam_role" "s3_access_role" {
  name        = local.iam_role_name
  # Updated description to reflect purpose
  description = "IAM role for accessing S3 with trust policies for Confluent Tableflow and Databricks Unity Catalog"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      # Statement 1 (Confluent): Allow Confluent Provider Integration Role to Assume this role
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
      # Statement 2 (Confluent): Allow Confluent Provider Integration Role to Tag Session
      {
        Effect    = "Allow"
        Principal = {
          AWS = confluent_provider_integration.main.aws[0].iam_role_arn
        }
        Action    = "sts:TagSession"
      },
      # Statement 3 (Databricks): Trust relationship for Databricks Root Account (from working example)
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = {
          # Trust the Root user of the Databricks account
          AWS = "arn:aws:iam::414351767826:root"
        },
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.databricks_account_id
          }
        }
      },
      # Statement 4 (Databricks): Trust relationship for UC Master Role and  Root (from working example)
      # IMPORTANT: The role's OWN ARN is NOT included in the Principal here,
      # resolving the MalformedPolicyDocument error.
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = {
          AWS = [
            # Trust the Databricks Unity Catalog Master Role ARN
            "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL",
            # Trust  AWS Account Root user
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.databricks_account_id
          },
          # Keep the ArnEquals condition from the working example's trust policy
          # This adds a condition based on the principal *making the call*
          ArnEquals = {
             "aws:PrincipalArn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.iam_role_name}"
          }
        }
      }
      # Note: If Databricks also requires the Service Principal "unity-catalog.service.databricks.com"
      # in the trust policy for storage credentials, you might need to add it to Statement 4's Principal block:
      # Principal = {
      #    Service = "unity-catalog.service.databricks.com",
      #    AWS = [ ... ]
      # }
      # --> Consult the *latest* Databricks Unity Catalog docs for the precise trust policy <--
    ]
  })
}

# --- NEW RESOURCE: Identity-based policy to grant the role permission to assume itself ---
# This policy is attached *to* the role (via the 'role' attribute)
# It defines what actions the role *can perform*, including assuming itself.
resource "aws_iam_role_policy" "s3_access_role_self_assume_policy" {
  name = "${local.iam_role_name}-self-assume" # Policy name
  role = aws_iam_role.s3_access_role.id      # Attach this policy to the S3 Access Role

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        # The Resource here is the ARN of the role itself.
        # This grants the role the *permission* to assume its own identity.
        Resource = aws_iam_role.s3_access_role.arn
      }
    ]
  })
  depends_on = [ aws_iam_role.s3_access_role ]
}


# --- Existing Policy Attachments ---
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
    role       = aws_iam_role.s3_access_role.name
    policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_glue_access" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}
