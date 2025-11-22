data "aws_caller_identity" "current" {}

locals {
  oidc_url  = aws_eks_cluster.this.identity[0].oidc[0].issuer
  oidc_host = replace(local.oidc_url, "https://", "")
}

data "aws_iam_openid_connect_provider" "this" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_host}"
}

output "oidc_provider_arn" {
  value = data.aws_iam_openid_connect_provider.this.arn
}

# data "aws_iam_openid_connect_provider" "this" {
#   arn = aws_eks_cluster.this.identity[0].oidc[0].issuer
# }

# output "oidc_provider_arn" {
#   value = data.aws_iam_openid_connect_provider.this.arn
# }

# resource "aws_iam_openid_connect_provider" "this" {
#   url = aws_eks_cluster.this.identity[0].oidc[0].issuer

#   client_id_list = ["sts.amazonaws.com"]
# }
