output "role_arn" {
  description = "ARN of the IAM role used for IRSA"
  value       = aws_iam_role.this.arn
}
