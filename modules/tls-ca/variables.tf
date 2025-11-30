variable "namespace" { type = string }
variable "configmap_name" {
  type    = string
  default = "aws-root-ca"
}
variable "ca_url" {
  type    = string
  default = "https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem"
}

variable "annotations" {
  type    = map(string)
  default = {}
}
variable "labels" {
  type    = map(string)
  default = {}
}
variable "namespace_dependency" {
  type        = any
  description = "Optional dependency to ensure namespace exists before ConfigMap"
  default     = null
}
