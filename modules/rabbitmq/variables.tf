variable "name" {
  description = "Name prefix (tenant-a, platform, etc)"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "subnet_ids" {
  type = list(string)

  validation {
    condition = (
        (var.publicly_accessible == true ||
        (var.publicly_accessible == false && length(var.subnet_ids) >= 1))
    )
    error_message = "For SINGLE_INSTANCE you must specify exactly 1 subnet; for CLUSTER_MULTI_AZ you must specify at least 2 subnets."
  }
}

variable "allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "allowed_security_groups" {
  type    = list(string)
  default = []
}

variable "admin_username" {
  type    = string
  default = "admin"
}

variable "engine_version" {
  type    = string
  default = "4.2"

  validation {
    condition     = contains(["4.2", "3.13"], var.engine_version)
    error_message = "Valid RabbitMQ versions are: 4.2, 3.13"
  }
}

variable "instance_type" {
  type    = string
  default = "mq.t3.micro"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "publicly_accessible" {
  type    = bool
  default = false
}
