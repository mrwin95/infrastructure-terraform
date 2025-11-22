data "aws_caller_identity" "current" {}
module "network" {
  source   = "../../modules/network"
  vpc_cidr = "10.30.0.0/16"
  azs      = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnet_cidrs = {
    "ap-northeast-1a" = "10.30.0.0/19"
    "ap-northeast-1c" = "10.30.32.0/19"
  }
  private_subnet_cidrs = {
    "ap-northeast-1a" = "10.30.96.0/19"
    "ap-northeast-1c" = "10.30.128.0/19"
  }

  tags = {
    stack_name = "blackowl-test"
  }
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.network.vpc_id
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "bos-test"
  cluster_version = "1.34"
  controlplane_sg = module.security.controlplane_sg
  private_subnets = module.network.private_subnets
  node_shared_sg  = module.security.shared_node_sg
  public_subnets  = module.network.public_subnets
  node_groups = {
    workers = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}

module "alb_irsa" {
  source = "../../modules/alb-irsa"

  cluster_name      = module.eks.cluster_name
  region            = "ap-northeast-1"
  vpc_id            = module.network.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
}

# module "alb" {
#   source       = "../../modules/alb-ingress"
#   cluster_name = module.eks.cluster_name
#   vpc_id       = module.network.vpc_id
#   region       = "ap-northeast-1"
# }

module "github_oidc" {
  source = "../../modules/github-oidc"

  role_name      = "github-actions-ecr"
  aws_region     = "ap-northeast-1"
  aws_account_id = data.aws_caller_identity.current.account_id

  github_org  = "thangca-dev"
  github_repo = "financial-lease"
  github_ref  = "ref:refs/heads/main"
}
