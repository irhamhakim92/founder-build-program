output "vpc_id" {
  description = "ID of the Cloud Starter Kit VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR range assigned to the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "public_subnet_cidr" {
  description = "CIDR range assigned to the public subnet."
  value       = aws_subnet.public.cidr_block
}

output "availability_zone" {
  description = "Availability Zone selected for the public subnet."
  value       = aws_subnet.public.availability_zone
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}
