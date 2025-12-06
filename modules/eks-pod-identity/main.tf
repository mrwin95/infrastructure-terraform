resource "aws_iam_role" "this" {
  for_each = var.workloads
  name     = "${var.name_prefix}-${each.key}-pod-identity-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.workloads
  name     = "${var.name_prefix}-${each.key}-inline-policy-role"
  role     = aws_iam_role.this[each.key].id
  policy   = each.value.policy_json
}

resource "kubernetes_service_account_v1" "this" {
  for_each = var.workloads
  metadata {
    name      = each.value.service_account_name
    namespace = each.value.namespace
  }
}

resource "aws_eks_pod_identity_association" "this" {
  for_each        = var.workloads
  cluster_name    = var.cluster_name
  namespace       = each.value.namespace
  service_account = kubernetes_service_account_v1.this[each.key].metadata[0].name
  role_arn        = aws_iam_role.this[each.key].arn
}
