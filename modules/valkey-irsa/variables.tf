variable "cluster_oidc_provider_arn" {
  type        = string
  description = "ARN of EKS OIDC Provider"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace for the service account"
}

variable "service_account_name" {
  type        = string
  description = "Kubernetes service account name"
}

variable "secret_name" {
  type        = string
  description = "Name of the secret in Secrets Manager"
}

variable "secret_string" {
  type        = string
  sensitive   = true
  description = "Sensitive string to store in Secrets Manager (Valkey password)"
}
