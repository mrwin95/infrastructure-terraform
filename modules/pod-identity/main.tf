locals {
  full_name = "${var.cluster_name}-${var.namespace}-${var.service_account}"
}

# -----------------------------------------------------
# IAM Role for Pod Identity
# -----------------------------------------------------
resource "aws_iam_role" "this" {
  name = "${local.full_name}-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      Condition = {
        StringEquals = {
          "aws:SourceIdentity" = var.service_account
        }
      }
    }]
  })

  tags = var.tags
}

# -----------------------------------------------------
# Attach Custom IAM Policies (Optional)
# -----------------------------------------------------
resource "aws_iam_role_policy" "inline" {
  # was: count = length(var.inline_policies) > 0 ? 1 : 0
  count = var.inline_policies == null ? 0 : 1

  name   = "${local.full_name}-inline"
  role   = aws_iam_role.this.name
  policy = jsonencode(var.inline_policies)
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# -----------------------------------------------------
# Pod Identity Association (role ↔ SA)
# -----------------------------------------------------
resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.this.arn
}
