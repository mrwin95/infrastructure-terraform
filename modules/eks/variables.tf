variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  default = "1.34"
  type    = string
}

variable "public_subnets" {
  type = set(string)
}

variable "private_subnets" {
  type = set(string)
}

variable "controlplane_sg" {
  type = string
}

variable "node_shared_sg" {
  type = string
}

variable "node_groups" {
  type = map(object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
  }))

  default = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 1
      min_size       = 1
      max_size       = 2
    }
  }
}

variable "vpc_id" {

}

variable "tags" {
  type    = map(string)
  default = {}
}
