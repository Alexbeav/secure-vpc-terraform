variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VPC"
  type        = map(string)
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}
