#####################################################################
# ServiceAccount for AWS Load Balancer Controller
# Annotated for IRSA (NOT Pod Identity)
#####################################################################

resource "kubernetes_service_account_v1" "alb" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
    }

    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}
