output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller_role.arn
}

output "alb_controller_policy_arn" {
  value = aws_iam_policy.alb_controller.arn
}