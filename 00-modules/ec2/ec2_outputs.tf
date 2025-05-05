output "public_ip" {
  value       = aws_instance.public.public_ip
  description = "Public IP address of the bastion host"
}

output "private_ip" {
  value       = aws_instance.private.private_ip
  description = "Private IP address of the private host"
}
