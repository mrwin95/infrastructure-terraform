##############################################
# GITHUB OIDC PROVIDER (only once per account)
##############################################
data "aws_iam_openid_connect_provider" "existing" {
  arn = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = data.aws_iam_openid_connect_provider.existing.arn != "" ? 0 : 1

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

locals {
  github_oidc_arn = (
    data.aws_iam_openid_connect_provider.existing.arn != ""
    ? data.aws_iam_openid_connect_provider.existing.arn
    : aws_iam_openid_connect_provider.github[0].arn
  )
}

##############################################
# IAM ROLE ASSUMED BY GITHUB ACTIONS
##############################################
resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = local.github_oidc_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:${var.github_ref}"
          }
        }
      }
    ]
  })
}

##############################################
# IAM POLICY FOR ECR PUSH
##############################################
resource "aws_iam_policy" "ecr" {
  name        = "${var.role_name}-policy"
  description = "Permissions for GitHub Actions to push to ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecr.arn
}
