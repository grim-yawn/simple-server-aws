provider "aws" {
  region = var.region
  profile = var.aws_profile
}

resource "aws_s3_bucket" "state" {
  bucket = var.backend_bucket_name
}