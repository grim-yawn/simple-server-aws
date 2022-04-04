# AWS configuration
variable "region" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}
variable "aws_secret_key" {
  type = string
}

# Server configuration
variable "server_image" {
  type = string
}
