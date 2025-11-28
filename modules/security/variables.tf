variable "vpc_id" {
  type = string
}

variable "shared_node_security_group" {
  default = "test-shared-node-sg"
}

variable "controlplane_security_group" {
  default = "test-controlplane-sg"
}
