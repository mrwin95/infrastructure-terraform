data "aws_caller_identity" "current" {}
resource "aws_secretsmanager_secret" "valkey_secret" {
  name        = var.secret_name
  description = "Valkey password or sensitive credentials"
}
resource "aws_secretsmanager_secret_version" "valkey_secret_version" {
  secret_id     = aws_secretsmanager_secret.valkey_secret.id
  secret_string = var.secret_string
}

resource "aws_iam_role" "irsa_role" {
  name = "${var.service_account_name}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.cluster_oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "oidc.eks.amazonaws.com/id/${replace(var.cluster_oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "secret_read_policy" {
  name        = "${var.service_account_name}-secret-read"
  description = "Allow Valkey service to read its SecretsManager secret"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource : aws_secretsmanager_secret.valkey_secret.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secret_policy" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.secret_read_policy.arn
}

resource "kubernetes_service_account" "valkey_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa_role.arn
    }
  }
}
