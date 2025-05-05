variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone to use"
  type        = string
  default     = "eu-west-1a"
}

variable "key_name" {
  description = "AWS key pair name to use for EC2"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project = "SecureCloudLab"
    Owner   = "your-name-or-team"
  }
}
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}
variable "my_ip" {
  description = "Your public IP address with CIDR mask, used for security group rules"
  type        = string
}
variable "project_name" {
  description = "Prefix used for naming resources and tags across the project"
  type        = string
  default     = "bastion-lab"
}