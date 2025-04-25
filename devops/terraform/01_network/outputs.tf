output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
  sensitive   = false
}

output "subnet_ids" {
  value       = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
  description = "The IDs of the subnets"
  sensitive   = false
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR block of the VPC"
  sensitive   = false
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