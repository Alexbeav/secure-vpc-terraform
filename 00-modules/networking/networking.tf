resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-igw"
  })
}

# Justification: Bastion needs a public IP to be accessed from the internet
# tfsec:ignore:aws-ec2-no-public-ip-subnet
resource "aws_subnet" "bastion" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-bastion-subnet"
  })
}

resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-subnet"
  })
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.bastion.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.bastion.id

  tags = merge(var.tags, {
    Name = "${var.project_name}-nat-gw"
  })
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-bastion-sg"
  })
}

resource "aws_security_group" "private" {
  name        = "${var.project_name}-private-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-private-sg"
  })
}

resource "aws_security_group_rule" "allow_ssh_from_my_ip" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = [var.my_ip]
  description       = "Allow SSH from your public IP"
}

resource "aws_security_group_rule" "allow_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Allow SSH from Bastion SG"
}

resource "aws_security_group_rule" "allow_icmp_from_bastion" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.private.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "Allow ICMP (ping) from bastion to private host"
}

resource "aws_security_group_rule" "allow_icmp_internal" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.private.id
  source_security_group_id = aws_security_group.private.id
  description              = "Allow ICMP within private SG"
}

# Justification: Bastion needs to be able to access the internet
resource "aws_security_group_rule" "egress_bastion" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
  description       = "Allow all outbound traffic from bastion"
}

# Justification: The private instance needs to be able to access the internet
# Note: this should be limited in scope in a production environment
resource "aws_security_group_rule" "egress_private" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
  description       = "Allow all outbound traffic from private"
}
