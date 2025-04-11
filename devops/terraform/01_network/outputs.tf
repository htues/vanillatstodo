output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block # Fix: Changed from .id to .cidr_block
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
}

output "subnet_cidrs" {
  description = "CIDR blocks of the created subnets"
  value = {
    subnet_a = aws_subnet.subnet_a.cidr_block
    subnet_b = aws_subnet.subnet_b.cidr_block
  }
}

output "route_table_id" {
  description = "ID of the main route table"
  value       = aws_route_table.main.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "availability_zones" {
  description = "Availability zones used by the subnets"
  value = {
    subnet_a = aws_subnet.subnet_a.availability_zone
    subnet_b = aws_subnet.subnet_b.availability_zone
  }
}