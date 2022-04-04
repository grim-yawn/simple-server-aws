variable "region" {
  default = "eu-west-1"
}

variable "aws_access_key_id" {
  type = string
}
variable "aws_secret_key" {
  type = string
}

variable "backend_bucket_name" {
  default = "terraform-backend-9yg4nnjdgw"
}

variable "backend_bucket_key" {
  default = "terraform/state"
}
