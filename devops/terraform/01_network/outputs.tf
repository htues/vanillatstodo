output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id
  ]
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.id
}