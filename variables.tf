# variables.tf

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

variable "availability_zone" {
  description = "Availability zone for subnet deployment"
  type        = string
  default     = "eu-west-1a"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "lab"
    project     = "secure-vpc"
  }
}
