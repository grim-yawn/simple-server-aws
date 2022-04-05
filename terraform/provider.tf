# We can't use variables in backend
terraform {
  required_version = ">=1.0"

  backend "s3" {
    region = "us-east-1"
    bucket = "terraform-backend-9yg4xhgdgw"
    key    = "terraform.tfstate"
  }
}

provider "aws" {
  region  = "us-east-1"
}
