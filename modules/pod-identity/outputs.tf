output "role_arn" {
  description = "IAM Role ARN assigned to the Pod Identity ServiceAccount"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "IAM Role name"
  value       = aws_iam_role.this.name
}

output "association_id" {
  description = "EKS Pod Identity association ID"
  value       = aws_eks_pod_identity_association.this.id
}
