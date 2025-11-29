data "aws_caller_identity" "current" {}
module "network" {
  source               = "../../modules/network"
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = {
    stack_name = var.stack_name
  }
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.network.vpc_id
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  controlplane_sg = module.security.controlplane_sg
  private_subnets = module.network.private_subnets
  node_shared_sg  = module.security.shared_node_sg
  public_subnets  = module.network.public_subnets
  node_groups = {
    workers = {
      instance_types = var.instance_types
      min_size       = var.node_group_min
      max_size       = var.node_group_max
      desired_size   = var.node_group_desired
    }
  }
}

module "alb_irsa" {
  source = "../../modules/alb-irsa"

  cluster_name      = module.eks.cluster_name
  region            = var.region
  vpc_id            = module.network.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
}

module "github_oidc" {
  source = "../../modules/github-oidc"

  role_name      = var.github_role_name
  aws_region     = var.region
  aws_account_id = data.aws_caller_identity.current.account_id

  github_org  = var.github_org
  github_repo = var.github_repo
  github_ref  = var.github_ref
}

module "external_dns" {
  source = "../../modules/external-dns"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn

  hosted_zone_id = var.hosted_zone_id
  domain_filters = var.domain_filters
}

module "valkey" {
  source = "../../modules/elasticache-valkey"

  name       = "dev"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnets

  allowed_security_groups = [
    module.security.shared_node_sg
  ]
  multi_az             = false
  cluster_mode_enabled = false
  #   engine_version = "valkey7"
  family     = var.valkey_family
  node_type  = "cache.t2.small"
  node_count = 1
  tags = {
    tenant = "tenant-a"
    env    = "prod"
  }
}
