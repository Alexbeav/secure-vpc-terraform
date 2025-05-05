output "public_ip" {
  value       = module.ec2.public_ip
  description = "Public IP address of the bastion host"
}

output "private_ip" {
  value       = module.ec2.private_ip
  description = "Private IP address of the private host"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC"
}

output "bastion_subnet_id" {
  value       = module.networking.bastion_subnet_id
  description = "ID of the public subnet used by the bastion host"
}

output "private_subnet_id" {
  value       = module.networking.private_subnet_id
  description = "ID of the private subnet"
}

output "bastion_sg_id" {
  value       = module.networking.bastion_sg_id
  description = "ID of the bastion security group"
}

output "private_sg_id" {
  value       = module.networking.private_sg_id
  description = "ID of the private security group"
}
