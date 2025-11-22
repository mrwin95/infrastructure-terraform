terraform {
  backend "s3" {
    bucket       = "winnguyen-terraform-state-2026"
    key          = "dev/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
  }
}
