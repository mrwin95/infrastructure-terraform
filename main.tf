data "aws_caller_identity" "current" {}
module "network" {
  source               = "./modules/network"
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = {
    stack_name = var.stack_name
  }
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  controlplane_sg = module.security.controlplane_sg
  private_subnets = module.network.private_subnets
  node_shared_sg  = module.security.shared_node_sg
  public_subnets  = module.network.public_subnets
  vpc_id          = module.network.vpc_id
  tags = {
    Org     = var.org
    Project = var.project
    Env     = var.env
    Cluster = var.cluster
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

# module "alb_pod_identity" {
#   source = "./modules/eks-pod-identity"
#   providers = {
#     kubernetes = kubernetes
#     helm       = helm
#     aws        = aws
#   }

#   cluster_name = module.eks.cluster_name
#   name_prefix  = terraform.workspace
#   workloads = {
#     alb = {
#       namespace            = "kube-system"
#       service_account_name = "aws-load-balancer-controller"

#       policy_json = file("${path.module}/policies/alb-controller-policy.json")
#     }
#   }
# }

module "alb" {
  source = "./modules/alb"
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name    = module.eks.cluster_name
  region          = var.region
  vpc_id          = module.network.vpc_id
  name_prefix     = terraform.workspace
  alb_policy_file = "${path.root}/policies/alb-controller-policy.json"
}

module "externaldns" {
  source = "./modules/external-dns"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name            = module.eks.cluster_name
  name_prefix             = terraform.workspace
  externaldns_policy_file = "${path.root}/policies/externaldns-policy.json"

  txt_owner_id   = "${terraform.workspace}-externaldns"
  domain_filters = var.domain_filters

  sources = ["ingress"]
}

# module "alb" {
#   source = "./modules/alb-irsa"

#   cluster_name      = module.eks.cluster_name
#   region            = var.region
#   vpc_id            = module.network.vpc_id
#   oidc_provider_arn = module.eks.oidc_provider_arn
# }

# module "oidc" {
#   source = "./modules/github-oidc"

#   role_name      = var.github_role_name
#   aws_region     = var.region
#   aws_account_id = data.aws_caller_identity.current.account_id

#   github_org  = var.github_org
#   github_repo = var.github_repo
#   github_ref  = var.github_ref
# }

# module "external_dns" {
#   source = "./modules/external-dns"

#   cluster_name      = module.eks.cluster_name
#   oidc_provider_arn = module.eks.oidc_provider_arn

#   hosted_zone_id = var.hosted_zone_id
#   domain_filters = var.domain_filters
# }

module "cache" {
  source = "./modules/elasticache-valkey"

  name       = var.cache_name
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnets

  allowed_security_groups = [
    module.eks.cluster_primary_sg
  ]
  multi_az             = var.cache_multi_az
  cluster_mode_enabled = var.cache_cluster_mode_enabled
  family               = var.cache_family
  node_type            = var.cache_node_type
  node_count           = var.cache_node_count
  tags = {
    Org     = var.org
    Project = var.project
    Env     = var.env
    Cluster = var.cluster
  }
}

module "rabbitmq_pod_identity" {
  source = "./modules/pod-identity"

  cluster_name    = module.eks.cluster_name
  namespace       = "messaging"
  service_account = "rabbitmq-client"

  inline_policies = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = module.rabbitmq.connection_secret_arn
      }
    ]
  }
}

module "rabbitmq" {
  source = "./modules/rabbitmq"

  name       = var.rabbitmq_name
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnets

  admin_username = var.rabbitmq_username
  admin_password = var.rabbitmq_password

  enable_pod_identity    = var.rabbitmq_pod_identity_enabled
  pod_identity_role_name = module.rabbitmq_pod_identity.role_name
  engine_version         = var.rabbitmq_engine_version
  deployment_mode        = var.rabbitmq_pod_identity_enabled ? "SINGLE_INSTANCE" : "CLUSTER_MULTI_AZ"
  instance_type          = var.rabbitmq_instance_type
}

# module "cache_irsa" {
#   source = "./modules/valkey-irsa"

#   cluster_oidc_provider_arn = module.eks.oidc_provider_arn
#   namespace                 = "platform"
#   service_account_name      = "valkey-client-sa"

#   secret_name   = "valkey/password/dev"
#   secret_string = var.secret_string
# }

# module "rabbitmq" {
#   source         = "./modules/rabbitmq"
#   name           = "dev"
#   instance_type  = "mq.t3.micro"
#   engine_version = "3.13"

#   vpc_id = module.network.vpc_id
#   subnet_ids = [
#     module.network.private_subnets[0]
#   ]

#   publicly_accessible = false
#   allowed_security_groups = [
#     module.eks.cluster_primary_sg,
#     module.security.shared_node_sg, module.security.controlplane_sg
#   ]

#   multi_az = false

#   tags = {
#     Org     = var.org
#     Project = var.project
#     Env     = var.env
#     Cluster = var.cluster
#   }
# }

# module "tls_ca" {
#   source               = "./modules/tls-ca"
#   namespace            = kubernetes_namespace.platform.metadata[0].name
#   namespace_dependency = kubernetes_namespace.platform
#   configmap_name       = "aws-root-ca"
# }

# module "ses_irsa" {
#   source                = "./modules/ses-irsa"
#   role_name             = var.ses_role_name
#   eks_oidc_provider_arn = module.eks.oidc_provider_arn
#   eks_oidc_provider_url = module.eks.oidc_host
#   namespace             = var.email_service_ns
#   service_account_name  = var.ses_service_account_name

#   tags = {
#     Org     = var.org
#     Project = var.project
#     Env     = var.env
#     Cluster = var.cluster
#   }
# }
