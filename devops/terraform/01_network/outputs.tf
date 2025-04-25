output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
  sensitive   = false
}

output "public_subnet_ids" {
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  description = "The IDs of the public subnets"
  sensitive   = false
}

output "private_subnet_ids" {
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  description = "The IDs of the private subnets"
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
    public_a  = aws_subnet.public_a.cidr_block
    public_b  = aws_subnet.public_b.cidr_block
    private_a = aws_subnet.private_a.cidr_block
    private_b = aws_subnet.private_b.cidr_block
  }
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = [aws_nat_gateway.nat_a.id, aws_nat_gateway.nat_b.id]
}

output "availability_zones" {
  description = "Availability zones used by the subnets"
  value = {
    public_a  = aws_subnet.public_a.availability_zone
    public_b  = aws_subnet.public_b.availability_zone
    private_a = aws_subnet.private_a.availability_zone
    private_b = aws_subnet.private_b.availability_zone
  }
}