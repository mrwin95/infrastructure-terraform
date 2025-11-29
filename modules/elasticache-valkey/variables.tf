variable "name" {
  description = "Name prefix for Valkey cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Valkey"
  type        = list(string)
}

variable "allowed_cidrs" {
  description = "CIDR ranges allowed to connect"
  type        = list(string)
  default     = []
}

variable "allowed_security_groups" {
  description = "Security groups allowed to connect"
  type        = list(string)
  default     = []
}

variable "node_type" {
  description = "Cache node type"
  type        = string
  default     = "cache.t2.micro"
}

variable "node_count" {
  description = "Number of nodes if cluster mode disabled"
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "Valkey version"
  type        = string
  default     = ""
}

variable "port" {
  description = "Port number"
  type        = number
  default     = 6379
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = true
}

variable "cluster_mode_enabled" {
  type    = bool
  default = false
}

variable "cluster_num_node_groups" {
  type    = number
  default = 0
}

variable "cluster_replicas_per_group" {
  type    = number
  default = 0
}

variable "parameters" {
  description = "Valkey parameter overrides"
  type        = map(string)
  default     = {}
}

variable "maintenance_window" {
  type    = string
  default = "sun:03:00-sun:04:00"
}

variable "snapshot_window" {
  type    = string
  default = "04:00-05:00"
}

variable "snapshot_retention_limit" {
  type    = number
  default = 5
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "family" {}
