variable "role_name" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}

variable "eks_oidc_provider_url" {
  type = string
}

variable "namespace" {
  type = string
}

variable "service_account_name" {
  type = string
}

variable "ses_actions" {
  type = list(string)
  default = [
    "ses:SendEmail",
    "ses:SendTemplateEmail",
    "ses:SendRawEmail"
  ]
}

variable "ses_resources" {
  type    = list(string)
  default = ["*"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
