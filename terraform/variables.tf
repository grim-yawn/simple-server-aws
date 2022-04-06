# AWS configuration
variable "region" {
  type = string
}

# Server configuration
variable "server_image" {
  type = string
}

# Profile
variable "aws_profile" {
  default = "terraform"
}