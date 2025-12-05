resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}
resource "aws_iam_role" "this" {

  depends_on = [kubernetes_namespace.ns]
  name       = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # IMPORTANT: audience is always sts.amazonaws.com for EKS IRSA
            "${var.eks_oidc_provider_url}:aud" = "sts.amazonaws.com"

            # Only this service account in this namespace can assume the role
            "${var.eks_oidc_provider_url}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "ses" {
  name        = "${var.role_name}-ses"
  description = "Allow SES send actions for IRSA role ${var.role_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.ses_actions
        Resource = var.ses_resources
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ses_attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ses.arn
}

resource "kubernetes_service_account" "sa" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.ns.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
  }

  depends_on = [kubernetes_namespace.ns]
}
