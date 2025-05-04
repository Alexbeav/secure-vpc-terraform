# modules/ec2/outputs.tf

output "public_ip" {
  value       = aws_instance.public.public_ip
  description = "Public IP address of the public instance"
}

output "private_ip" {
  value       = aws_instance.private.private_ip
  description = "Private IP address of the private instance"
}
