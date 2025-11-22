##########################################################
# Kubernetes ServiceAccount required BEFORE Pod Identity
##########################################################

resource "kubernetes_service_account" "alb" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}
