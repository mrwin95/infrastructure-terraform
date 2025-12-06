variable "hosted_zone_id" {}
variable "domain_filters" { type = list(string) }
variable "bucket_terraform_s3" {}
variable "region" {}
variable "vpc_cidr" {}
variable "azs" { type = list(string) }
variable "public_subnet_cidrs" { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }
variable "stack_name" {}
variable "cluster_name" {}
variable "cluster_version" {}
variable "node_group_min" {}
variable "node_group_max" {}
variable "node_group_desired" {}
variable "instance_types" { type = list(string) }
variable "github_role_name" {}
variable "github_org" {}
variable "github_repo" {}
variable "github_ref" {}
variable "valkey_family" {}
variable "secret_string" {}
variable "ses_role_name" {}
variable "ses_service_account_name" {}
variable "email_service_ns" {}

variable "org" {
  type    = string
  default = "bos"
}

variable "project" {
  type    = string
  default = "eks"
}

variable "env" {
  type        = string
  description = "Environment: prod | qa | test | dev"
}

variable "cluster" {
  type        = string
  description = "Cluster name: blue | green | prod"
}
