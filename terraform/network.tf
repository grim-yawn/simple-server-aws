# Use this VPC instead of default
resource "aws_vpc" "production" {
  cidr_block = "10.0.0.0/16"
}

# Public subnet in first availability zone
resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.production.id

  cidr_block        = "10.0.1.0/25"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "private | a"
  }
}

# Private subnet in first availability zone
resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.production.id

  cidr_block        = "10.0.2.0/25"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "public | a"
  }
}

# Public subnet in second availability zone
resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.0.1.128/25"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "private | b"
  }
}

# Private subnet in first availability zone
resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.production.id
  cidr_block = "10.0.2.128/25"

  tags = {
    "Name" = "public | b"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.production.id

  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table_association" "public_a_subnet" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_a.id
}

resource "aws_route_table_association" "public_b_subnet" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_b.id
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.production.id

  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "private_a_subnet" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_a.id
}

resource "aws_route_table_association" "private_b_subnet" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_b.id
}


# Elastic IP
resource "aws_eip" "nat" {
  vpc = true
}

# Public access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.production.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Private access
resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat.id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.ngw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Security group for http from all IPs
resource "aws_security_group" "http" {
  name        = "http"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.production.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group to access from vpc to all
resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "All outbound traffic"
  vpc_id      = aws_vpc.production.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_server_all" {
  name        = "ingress-server"
  description = "Allow ingress to Server"
  vpc_id      = aws_vpc.production.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}