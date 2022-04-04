provider "aws" {
  region = var.region

  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_key
}

resource "aws_s3_bucket" "state" {
  bucket = var.backend_bucket_name
}