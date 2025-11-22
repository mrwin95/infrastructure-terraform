variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace of the service account"
}

variable "service_account" {
  type        = string
  description = "Kubernetes service account name"
}

variable "role_name" {
  type        = string
  description = "Name for the IAM role"
}

variable "policy_json_path" {
  type        = string
  default     = null
  description = "Path to an IAM policy.json file. If null, no inline policy will be created."
}

variable "managed_policy_arns" {
  type        = list(string)
  default     = []
  description = "Optional list of AWS managed policy ARNs"
}
