# modules/networking/variables.tf

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
variable "my_ip" {
  description = "User's public IP in CIDR format (e.g., 1.2.3.4/32)"
  type        = string
}
