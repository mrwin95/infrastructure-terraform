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
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}
