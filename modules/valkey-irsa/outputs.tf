output "service_account_name" {
  value = kubernetes_service_account.valkey_sa.metadata[0].name
}

output "secret_arn" {
  value = aws_secretsmanager_secret.valkey_secret.arn
}

output "irsa_role_arn" {
  value = aws_iam_role.irsa_role.arn
}
