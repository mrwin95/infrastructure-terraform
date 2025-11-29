terraform {
  backend "s3" {
    bucket         = "winnguyen-terraform-state-2026"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    use_lockfile   = true
    encrypt        = true
    dynamodb_table = "winnguyen-terraform-locks"
  }
}
