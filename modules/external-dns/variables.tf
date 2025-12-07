variable "cluster_name" {
  type        = string
  description = "EKS cluster name (for txtOwnerId uniqueness, logging, etc.)"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for IAM role names (e.g., workspace or env)"
}

variable "externaldns_policy_file" {
  type        = string
  description = "Path to ExternalDNS Route53 IAM policy JSON"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace where ExternalDNS will run"
}

variable "service_account_name" {
  type        = string
  default     = "external-dns"
  description = "Kubernetes ServiceAccount name for ExternalDNS"
}

variable "chart_version" {
  type        = string
  default     = "1.14.0"
  description = "Helm chart version for external-dns"
}

variable "txt_owner_id" {
  type        = string
  description = "TXT owner ID used by ExternalDNS to identify its records"
}

variable "domain_filters" {
  type        = list(string)
  default     = []
  description = "List of domain filters for ExternalDNS (optional)"
}

variable "sources" {
  type        = list(string)
  default     = ["ingress"]
  description = "ExternalDNS sources (default: ingress)"
}

variable "log_level" {
  type        = string
  default     = "info"
  description = "ExternalDNS log level"
}
