output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_id" {
  value = aws_eks_cluster.this.id
}

output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_role_arn" {
  value = aws_iam_role.node_role.arn
}

output "node_groups" {
  value = [for ng in aws_eks_node_group.managed : ng.node_group_name]
}

# output "oidc_provider_arn" {
#   description = "OIDC provider ARN for IRSA"
#   value       = aws_iam_openid_connect_provider.this.arn
# }
