# Create VPC with DNS support
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name                                        = "${var.environment}-vanillatstodo-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-vanillatstodo-igw"
  }
}

# Create public subnets
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs["a"]
  availability_zone = "${var.aws_region}a"

  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                        = "${var.environment}-public-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs["b"]
  availability_zone = "${var.aws_region}b"

  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                        = "${var.environment}-public-b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  })
}

# Create Private Subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs["a"]
  availability_zone = "${var.aws_region}a"

  tags = merge(var.tags, {
    Name                                        = "${var.environment}-private-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs["b"]
  availability_zone = "${var.aws_region}b"

  tags = merge(var.tags, {
    Name                                        = "${var.environment}-private-b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-public"
    Environment = var.environment
  }
}

# Create private route tables for NAT gateways
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Name        = "${var.environment}-private-a"
    Environment = var.environment
  }
  depends_on = [aws_nat_gateway.nat_a]
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }

  tags = {
    Name        = "${var.environment}-private-b"
    Environment = var.environment
  }
  depends_on = [aws_nat_gateway.nat_b]
}

# Create Route table associations
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

# Create NAT Gateways
resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags = {
    Name        = "${var.environment}-nat-a"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name        = "${var.environment}-nat-a"
    Environment = var.environment
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags = {
    Name        = "${var.environment}-nat-b"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name        = "${var.environment}-nat-b"
    Environment = var.environment
  }
  depends_on = [aws_internet_gateway.main]
}

resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.environment}-vpc-endpoints-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-vpc-endpoints-sg"
    Environment = var.environment
  }
}

# VPC Endpoints for EKS private access
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id
  ]

  tags = {
    Name        = "${var.environment}-s3-endpoint"
    Environment = var.environment
  }
}

# Update ECR API endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false # Changed from true to false

  tags = {
    Name        = "${var.environment}-ecr-api-endpoint"
    Environment = var.environment
  }
  depends_on = [aws_route_table.private_a, aws_route_table.private_b]
}

# Update ECR DKR endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = false # Changed from true to false

  tags = {
    Name        = "${var.environment}-ecr-dkr-endpoint"
    Environment = var.environment
  }
  depends_on = [aws_route_table.private_a, aws_route_table.private_b]
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Optional: VPC Flow Logs
resource "aws_flow_log" "main" {
  iam_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.environment}-vanillatstodo-vpc-flow-log-role"
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-vpc-flow-log"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/${var.environment}-flow-logs"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-vpc-flow-log-group"
    Environment = var.environment
  }
}
