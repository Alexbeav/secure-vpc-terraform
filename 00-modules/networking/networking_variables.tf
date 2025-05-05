variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone to deploy into"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public (bastion) subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "my_ip" {
  description = "Your public IP in CIDR format (e.g. 203.0.113.1/32)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "project_name" {
  description = "Project name used as a naming prefix"
  type        = string
}
