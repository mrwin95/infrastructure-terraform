variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for ALB"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for IAM roles"
}

variable "alb_policy_file" {
  type        = string
  description = "Path to ALB IAM policy JSON"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace for AWS Load Balancer Controller"
}

variable "service_account_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "Kubernetes ServiceAccount name"
}

variable "chart_version" {
  type    = string
  default = "1.9.0" # Latest stable
}
