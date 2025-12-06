variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for IAM role names"
  default     = "podid"
}

variable "workloads" {
  type = map(object({
    namespace            = string
    service_account_name = string
    policy_json          = string # Inline IAM policy for workload
  }))

  description = <<EOF
Map of workloads to create Pod Identity associations for.

Example:
{
  "externaldns" = {
    namespace            = "kube-system"
    service_account_name = "external-dns"
    policy_json          = jsonencode({ ... })
  }
}
EOF
}
