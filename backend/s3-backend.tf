provider "aws" {
  region  = "ap-northeast-1"
  profile = "winsso-sam"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "winnguyen-terraform-state-2026"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
