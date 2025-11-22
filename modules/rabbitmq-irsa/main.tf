resource "aws_iam_policy" "rabbitmq_secrets" {
  name        = "${var.cluster_name}-rabbitmq-secrets"
  description = "Allow EKS apps to read RabbitMQ Secrets Manager credentials"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = var.rabbitmq_secret_arn
      }
    ]
  })
}

resource "aws_iam_role" "rabbitmq_role" {
  name = "${var.cluster_name}-rabbitmq-irsa"

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

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.rabbitmq_role.name
  policy_arn = aws_iam_policy.rabbitmq_secrets.arn
}

# IRSA association
resource "aws_eks_pod_identity_association" "rabbitmq" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.rabbitmq_role.arn
}
