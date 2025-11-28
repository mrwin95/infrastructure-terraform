variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "namespace" {
  description = "Namespace for ExternalDNS"
  type        = string
  default     = "external-dns"
}

variable "create_namespace" {
  type    = bool
  default = true
}

variable "zone_type" {
  description = "public or private hosted zone"
  type        = string
  default     = "public"
}

variable "hosted_zone_id" {
  description = "Optional specific hosted zone ID"
  type        = string
  default     = null
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN from EKS module"
  type        = string
}

variable "policy_name" {
  description = "Name for IAM policy"
  type        = string
  default     = "external-dns-policy"
}

variable "chart_version" {
  type        = string
  default     = "1.15.0"
}

variable "domain_filters" {
  description = "Optional restrict domains ExternalDNS can modify"
  type        = list(string)
  default     = []
}
