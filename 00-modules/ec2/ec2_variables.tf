variable "ami_id" {
  description = "AMI to use for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 Key Pair"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
}

variable "bastion_subnet_id" {
  description = "Subnet ID for the public-facing bastion host"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID for the private EC2 instance"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID for the bastion host"
  type        = string
}

variable "private_sg_id" {
  description = "Security group ID for the private host"
  type        = string
}
