output "service_account" {
  value = module.pod_identity.service_account_names["alb"]
}

output "role_arn" {
  value = module.pod_identity.role_arns["alb"]
}
