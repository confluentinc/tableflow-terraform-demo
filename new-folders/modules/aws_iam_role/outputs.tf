output "role_name" {
  description = "The name of the IAM role created for S3 access."
  value       = aws_iam_role.s3_access_role.name
}

output "role_arn" {
  description = "The ARN of the IAM role created for S3 access."
  value       = aws_iam_role.s3_access_role.arn
}

output "policy_arn" {
  description = "The ARN of the IAM policy attached to the role."
  value       = aws_iam_policy.s3_access_policy.arn
}