variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = map(string)
}

variable "private_subnet_cidrs" {
  type = map(string)
}

variable "tags" {
  type = map(string)
  default = {
  }
}
