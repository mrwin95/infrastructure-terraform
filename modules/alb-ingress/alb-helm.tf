##########################################################
# Helm installation of AWS Load Balancer Controller
##########################################################

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = false
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.alb.metadata[0].name
    }
  ]

  depends_on = [
    aws_eks_pod_identity_association.alb
  ]
}
