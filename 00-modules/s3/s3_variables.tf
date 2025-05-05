variable "vpc_id" {
  description = "VPC ID where the S3 VPC endpoint will be created"
  type        = string
  default     = ""
}

variable "route_table_ids" {
  description = "List of route table IDs to associate with the VPC endpoint"
  type        = list(string)
  default     = []
}
