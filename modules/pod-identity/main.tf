############################################
# IAM Role for Pod Identity
############################################

resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

############################################
# Optional: attach inline IAM policy JSON file
############################################

resource "aws_iam_policy" "this" {
  count       = var.policy_json_path != null ? 1 : 0
  name        = "${var.role_name}-policy"
  description = "IAM policy for ${var.role_name}"

  policy = file(var.policy_json_path)
}

resource "aws_iam_role_policy_attachment" "attach" {
  count      = var.policy_json_path != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

############################################
# Optional: attach pre-existing AWS policies
############################################

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

############################################
# Pod Identity Association
############################################

resource "aws_eks_pod_identity_association" "this" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.this.arn
}
