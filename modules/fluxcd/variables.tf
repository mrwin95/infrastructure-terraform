variable "namespace" {
  type    = string
  default = "flux-system"
}

variable "service_account" {
  type    = string
  default = "flux"
}

variable "flux_version" {
  type    = string
  default = "2.12.0"
}

variable "pod_identity_role_arn" {
  type        = string
  description = "IAM role ARN produced by the eks-pod-identity module"
}
