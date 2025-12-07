org            = "winnguyen"
project        = "fluxcd"
env            = "dev"
cluster        = "dev"
hosted_zone_id = "Z035780024TVHHHAD6UK7"
domain_filters = ["thangca.dev"]
region         = "ap-northeast-1"
vpc_cidr       = "10.30.0.0/16"
azs            = ["ap-northeast-1a", "ap-northeast-1c"]
public_subnet_cidrs = {
  "ap-northeast-1a" = "10.30.0.0/19"
  "ap-northeast-1c" = "10.30.32.0/19"
}

private_subnet_cidrs = {
  "ap-northeast-1a" = "10.30.96.0/19"
  "ap-northeast-1c" = "10.30.128.0/19"
}

stack_name      = "dev"
cluster_name    = "dev"
cluster_version = "1.34"

node_group_min     = 0
node_group_max     = 2
node_group_desired = 1

instance_types = ["t3.medium"]

github_role_name           = "github-actions-ecr"
github_repo                = "thangca-dev"
github_ref                 = "ref:refs/heads/main"
bucket_terraform_s3        = "winnguyen-terraform-state-2026"
github_org                 = ""
cache_name                 = "valkey-dev"
cache_family               = "valkey7"
cache_multi_az             = false
cache_cluster_mode_enabled = false
cache_node_type            = "cache.t2.micro"
cache_node_count           = 1
secret_string              = "Thang123456"
ses_role_name              = "eks-ses-irsa-role"
ses_service_account_name   = "ses-sender-sa"
email_service_ns           = "email-service"
