# modules/ec2/variables.tf

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the existing key pair"
  type        = string
}

variable "public_subnet_id" {
  description = "Subnet ID for the public EC2"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID for the private EC2"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to attach to instances"
  type        = string
}

variable "tags" {
  description = "Common tags for EC2 instances"
  type        = map(string)
  default     = {}
}
