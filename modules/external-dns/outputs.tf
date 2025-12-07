output "service_account" {
  description = "ServiceAccount used by ExternalDNS"
  value       = module.pod_identity.service_account_names["externaldns"]
}

output "role_arn" {
  description = "IAM role ARN used by ExternalDNS via Pod Identity"
  value       = module.pod_identity.role_arns["externaldns"]
}

output "helm_release_name" {
  description = "Name of the ExternalDNS Helm release"
  value       = helm_release.externaldns.name
}
