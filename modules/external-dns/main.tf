locals {
  sa_name = var.service_account_name
  ns      = var.namespace
}

module "pod_identity" {
  source = "../eks-pod-identity"

  providers = {
    kubernetes = kubernetes
  }

  cluster_name = var.cluster_name
  name_prefix  = "${var.name_prefix}-externaldns"

  workloads = {
    externaldns = {
      namespace            = local.ns
      service_account_name = local.sa_name
      policy_json          = file(var.externaldns_policy_file)
    }
  }
}

resource "helm_release" "externaldns" {
  name       = "external-dns"
  namespace  = local.ns
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.chart_version

  values = [
    yamlencode({
      provider = "aws"
      policy   = "sync"

      serviceAccount = {
        create = false # we create SA via Pod Identity module
        name   = local.sa_name
      }

      txtOwnerId = var.txt_owner_id
      sources    = var.sources
      logLevel   = var.log_level
      domainFilters = (
        length(var.domain_filters) > 0
        ? var.domain_filters
        : null
      )
    })
  ]

  depends_on = [
    module.pod_identity
  ]
}
