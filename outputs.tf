output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.lab.id
}

output "route_table_id" {
  value = aws_route_table.public.id
}
output "vpc_id" {
  value = aws_vpc.lab.id
}

output "public_subnet_cidr" {
  value = aws_subnet.public.cidr_block
}

output "security_group_id" {
  value = aws_security_group.allow_ssh_icmp.id
}
