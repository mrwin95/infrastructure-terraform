variable "name" {
  type        = string
  description = "Base name for RabbitMQ resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for RabbitMQ"

  validation {
    condition = (
      (var.deployment_mode == "SINGLE_INSTANCE" && length(var.subnet_ids) >= 1) ||
      (var.deployment_mode == "CLUSTER_MULTI_AZ" && length(var.subnet_ids) >= 2)
    )
    error_message = "SINGLE_INSTANCE requires ≥1 subnet. CLUSTER_MULTI_AZ requires ≥2 subnets."
  }
}

variable "allowed_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDR blocks allowed to connect to RabbitMQ"
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "Security groups allowed to connect to RabbitMQ"
}

variable "port" {
  type        = number
  default     = 5671 # TLS port
  description = "RabbitMQ broker port (TLS)"
}

variable "engine_version" {
  type        = string
  default     = "3.13.2"
  description = "RabbitMQ engine version for Amazon MQ"
}

variable "instance_type" {
  type        = string
  default     = "mq.m5.large"
  description = "Amazon MQ broker instance type"
}

variable "deployment_mode" {
  type        = string
  default     = "SINGLE_INSTANCE"
  description = "RabbitMQ deployment mode: SINGLE_INSTANCE | CLUSTER_MULTI_AZ (valid for engine_type=RabbitMQ)"

  validation {
    condition     = contains(["SINGLE_INSTANCE", "CLUSTER_MULTI_AZ"], var.deployment_mode)
    error_message = "For engine_type=RabbitMQ, deployment_mode must be SINGLE_INSTANCE or CLUSTER_MULTI_AZ."
  }
}

variable "admin_username" {
  type        = string
  default     = "admin"
  description = "RabbitMQ admin username"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "RabbitMQ admin password"
}

variable "vhost" {
  type        = string
  default     = "/"
  description = "Default virtual host"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# --- Pod Identity integration ---

variable "enable_pod_identity" {
  type        = bool
  default     = false
  description = "If true, attach a Secrets Manager access policy to the given IAM role name"
}

variable "pod_identity_role_name" {
  type        = string
  default     = ""
  description = "IAM role name created by pod_identity module for the RabbitMQ client service account"
}
