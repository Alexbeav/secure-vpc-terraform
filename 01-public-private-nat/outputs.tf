# 01-public-private-nat/outputs.tf

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID from the VPC module"
}

output "public_subnet_id" {
  value       = module.networking.public_subnet_id
  description = "Public subnet ID"
}

output "private_subnet_id" {
  value       = module.networking.private_subnet_id
  description = "Private subnet ID"
}

output "security_group_id" {
  value       = module.networking.security_group_id
  description = "Security Group ID"
}
