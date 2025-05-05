output "bastion_subnet_id" {
  value       = aws_subnet.bastion.id
  description = "ID of the public subnet used by the bastion"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "ID of the private subnet"
}

output "bastion_sg_id" {
  value       = aws_security_group.bastion.id
  description = "ID of the bastion security group"
}

output "private_sg_id" {
  value       = aws_security_group.private.id
  description = "ID of the private instance security group"
}
