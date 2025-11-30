data "http" "amazon_root_ca1" {
  url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"
}

data "http" "amazon_intermediate_g5" {
  url = "https://www.amazontrust.com/repository/AmazonIntermediateCAG5.pem"
}

# data "http" "aws_ca" {
#   url = var.ca_url
# }

resource "local_file" "aws_ca_file" {
  content  = "${data.http.amazon_root_ca1.response_body}\n${data.http.amazon_intermediate_g5.response_body}" #data.http.aws_ca.response_body
  filename = "${path.module}/aws-ca.pem"
}

resource "local_file" "combined_aws_ca" {
  content  = "${data.http.amazon_root_ca1.response_body}\n${data.http.amazon_intermediate_g5.response_body}"
  filename = "${path.module}/aws-combined-ca.pem"
}

resource "kubernetes_config_map" "aws_ca" {
  metadata {
    name        = var.configmap_name
    namespace   = var.namespace
    labels      = var.labels
    annotations = var.annotations
  }

  data = {
    "aws-ca.pem" = "${data.http.amazon_root_ca1.response_body}\n${data.http.amazon_intermediate_g5.response_body}"
  }
  #   data = {
  #     "aws-ca.pem" = data.http.aws_ca.response_body
  #   }

  depends_on = [
    var.namespace_dependency
  ]
}
