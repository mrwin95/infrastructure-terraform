variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID"
}

variable "role_name" {
  type        = string
  description = "IAM role name for GitHub Actions"
}

variable "github_org" {
  type        = string
  description = "GitHub organization or user"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "github_ref" {
  type        = string
  description = "Allowed ref, e.g. 'ref:refs/heads/main' or '*'"
  default     = "*"
}
