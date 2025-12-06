output "role_arns" {
  value = { for k, v in aws_iam_role.this : k => v.arn }
}

output "service_account_names" {
  value = {
    for k, sa in kubernetes_service_account_v1.this :
    k => "${sa.metadata[0].namespace}/${sa.metadata[0].name}"
  }
}

output "pod_identity_associations" {
  value = {
    for k, v in aws_eks_pod_identity_association.this :
    k => v.id
  }
}
