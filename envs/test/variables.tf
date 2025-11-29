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
