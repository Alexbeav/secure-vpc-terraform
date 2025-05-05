# Secure VPC Terraform Lab
# Scenario 01: Public + Private Subnets with NAT Gateway
# Goal: Create a general-purpose VPC with internet access for public EC2, and NAT for private EC2

module "vpc" {
  source         = "../00-modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  tags           = var.tags
}

module "networking" {
  source = "../00-modules/networking"

  vpc_id              = module.vpc.vpc_id
  availability_zone   = var.availability_zone
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  my_ip               = var.my_ip
  tags                = var.tags
}

module "ec2" {
  source = "../00-modules/ec2"

  public_subnet_id  = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id
  security_group_id = module.networking.security_group_id
  key_name          = var.key_name
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  tags              = var.tags
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "private_ip" {
  value = module.ec2.private_ip
}
