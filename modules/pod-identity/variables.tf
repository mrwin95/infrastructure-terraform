variable "cluster_name" {
  type        = string
  description = "EKS cluster name used for pod identity association"
}

variable "namespace" {
  type        = string
  description = "Namespace of the Kubernetes ServiceAccount"
}

variable "service_account" {
  type        = string
  description = "ServiceAccount name that will assume this IAM role"
}

variable "managed_policy_arns" {
  type        = list(string)
  default     = []
  description = "List of AWS managed policies to attach to the IAM role"
}

variable "inline_policies" {
  # was: type = map(any)
  type        = any
  default     = null
  description = "Inline policy document (unencoded). Will be jsonencoded inside the module."
}

variable "tags" {
  type    = map(string)
  default = {}
}
