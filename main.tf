# main.tf
provider "aws" {
  region  = "eu-west-1"
  profile = "crosstalkis-admin"
}

# VPC
resource "aws_vpc" "lab" {
  cidr_block = var.vpc_cidr_block

  tags = merge(var.tags, {
    Name = "lab-vpc"
  })
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "lab-igw"
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(var.tags, {
    Name = "lab-public-subnet"
  })
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = {
    Name = "lab-public-rt"
  }
}

# ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# SECURITY GROUP
# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "allow_ssh_icmp" {
  name        = "lab-sg"
  description = "Allow SSH and ICMP (lab use)"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "Allow SSH from your WAN IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["89.210.77.154/32"]
  }

  ingress {
    description = "Allow ICMP (ping) from your WAN IP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    # tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["89.210.77.154/32"]
  }

  egress {
    description = "Allow all outbound traffic (lab only)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "lab-sg"
  })
}
