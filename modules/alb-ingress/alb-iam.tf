########################################
# IAM Policy for ALB Ingress Controller
########################################

resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/iam_policy.json")
}

########################################
# IAM Role for Pod Identity
########################################
resource "aws_iam_role" "alb_controller_role" {
  name = "${var.cluster_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "pods.eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller_role.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

########################################
# Pod Identity Association
########################################
resource "aws_eks_pod_identity_association" "alb" {
  cluster_name    = var.cluster_name
  namespace       = "kube-system"
  service_account = kubernetes_service_account.alb.metadata[0].name
  role_arn        = aws_iam_role.alb_controller_role.arn

  depends_on = [
    kubernetes_service_account.alb,
    aws_iam_role_policy_attachment.alb_attach
  ]
}
