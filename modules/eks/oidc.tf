data "aws_caller_identity" "current" {}

// If oidc havent created yet open this out otherwise please import
resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd40df0"]

  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

locals {
  oidc_url  = aws_eks_cluster.this.identity[0].oidc[0].issuer
  oidc_host = replace(local.oidc_url, "https://", "")
}

# data "aws_iam_openid_connect_provider" "this" {
#   arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_host}"
# }


output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

#  terraform import \
#     aws_iam_openid_connect_provider.this \
#    arn:aws:iam::965090468640:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/D53BB83C441EF6749E5F2F6F66429110
