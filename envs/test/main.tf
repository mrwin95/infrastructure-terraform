data "aws_caller_identity" "current" {}
resource "kubernetes_namespace" "platform" {
  metadata {
    name = "platform"
  }
}
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
  vpc_id          = module.network.vpc_id
  tags = {
    Project = "Test"
    Env     = "dev"
  }
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
    # module.security.shared_node_sg
    module.eks.cluster_primary_sg
  ]
  multi_az             = false
  cluster_mode_enabled = false
  family               = var.valkey_family
  node_type            = "cache.t2.small"
  node_count           = 1
  tags = {
    tenant = "tenant-a"
    env    = "prod"
  }
}

module "rabbitmq" {
  source         = "../../modules/rabbitmq"
  name           = "dev"
  instance_type  = "mq.t3.micro"
  engine_version = "3.13"

  vpc_id = module.network.vpc_id
  subnet_ids = [
    module.network.private_subnets[0]
  ]

  publicly_accessible = false
  allowed_security_groups = [
    module.eks.cluster_primary_sg,
    module.security.shared_node_sg, module.security.controlplane_sg
  ]

  multi_az = false

  tags = {
    tenant = "dev"
    env    = "prod"
  }
}

module "tls_ca" {
  source               = "../../modules/tls-ca"
  namespace            = kubernetes_namespace.platform.metadata[0].name
  namespace_dependency = kubernetes_namespace.platform
  configmap_name       = "aws-root-ca"
}

module "valkey_irsa" {
  source = "../../modules/valkey-irsa"

  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  namespace                 = "platform"
  service_account_name      = "valkey-client-sa"

  secret_name   = "valkey/password/dev"
  secret_string = var.secret_string
}
