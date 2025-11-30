output "configmap_name" {
  description = "Name of the ConfigMap containing AWS CA bundle"
  value       = kubernetes_config_map.aws_ca.metadata[0].name
}

output "configmap_namespace" {
  description = "Namespace where AWS CA ConfigMap was created"
  value       = kubernetes_config_map.aws_ca.metadata[0].namespace
}

output "mount_path" {
  description = "Standard mount path to use in K8s deployments"
  value       = "/etc/aws-ca/aws-ca.pem"
}
