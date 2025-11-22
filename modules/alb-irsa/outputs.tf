output "alb_role_arn" {
  value = aws_iam_role.alb_controller_role.arn
}

output "alb_sa_name" {
  value = kubernetes_service_account.alb.metadata[0].name
}
