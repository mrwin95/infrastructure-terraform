# Create namespace
resource "kubernetes_namespace_v1" "flux_ns" {
  metadata {
    name = var.namespace
  }
}

# Install FluxCD via Helm
resource "helm_release" "flux" {
  name       = "flux2"
  namespace  = var.namespace
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = var.flux_version

  depends_on = [
    kubernetes_namespace_v1.flux_ns
  ]

  values = [
    yamlencode({
      installCRDs = true

      serviceAccount = {
        create = true
        name   = var.service_account
        annotations = {
          "eks.amazonaws.com/pod-identity-arn" = var.pod_identity_role_arn
        }
      }

      metrics = {
        enabled = true
      }
    })
  ]
}
