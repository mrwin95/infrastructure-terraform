locals {
  sa_name = var.service_account_name
  ns      = var.namespace
}

module "pod_identity" {
  source = "../eks-pod-identity"
  # reuse root providers
  providers = {
    kubernetes = kubernetes
  }
  cluster_name = var.cluster_name
  name_prefix  = "${var.name_prefix}-alb"

  workloads = {
    alb = {
      namespace            = local.ns
      service_account_name = local.sa_name
      policy_json          = file(var.alb_policy_file)
    }
  }
}

resource "helm_release" "alb" {
  name       = "aws-load-balancer-controller"
  namespace  = local.ns
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_version

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.region
      vpcId       = var.vpc_id

      serviceAccount = {
        create = false
        name   = local.sa_name
      }

      podIdentity = {
        enabled = true
      }

      logLevel = "info"
    })
  ]

  depends_on = [
    module.pod_identity
  ]
}
