# modules/networking/main.tf

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "lab-igw"
  })
}

# Justification: Bastion needs a public IP to be accessed from the internet
# tfsec:ignore:aws-ec2-no-public-ip-subnet
resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "lab-public-subnet"
  })
}

resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(var.tags, {
    Name = "lab-private-subnet"
  })
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "lab-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "lab-nat-gw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "lab-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "default" {
  name        = "lab-sg"
  description = "Allow SSH and ICMP"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "lab-sg"
  })
}

# Justification: Allowing all outbound traffic for NAT gateway
# tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
  description       = "Allow all outbound traffic for updates or NAT gateway"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_ssh_self" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.default.id
  description       = "Allow SSH from public IP"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_icmp_self" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.default.id
  source_security_group_id = aws_security_group.default.id
  cidr_blocks              = [var.my_ip]
  description              = "Allow ICMP from same SG"

  lifecycle {
    create_before_destroy = true
  }
}
