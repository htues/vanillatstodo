provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "vanillatstodo"
      ManagedBy   = "terraform"
    }
  }
}

# Create VPC with DNS support
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vanillatstodo-vpc"
  }
}

# Update subnet configurations with proper tagging for EKS
resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "vanillatstodo-subnet-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "vanillatstodo-igw"
    Environment = "staging"
  }
}

# Create Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "vanillatstodo-rt"
    Environment = "staging"
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.main.id
}

# Update EKS security group
resource "aws_security_group" "eks" {
  vpc_id      = aws_vpc.main.id
  name_prefix = "eks-cluster-"
  description = "Security group for EKS cluster"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "vanillatstodo-eks-sg"
    Environment = "staging"
  }
}

# Add timeout for EKS cluster creation
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.27" # Specify Kubernetes version

  vpc_config {
    subnet_ids              = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  timeouts {
    create = "30m"
    delete = "15m"
  }

  depends_on = [
    aws_cloudwatch_log_group.eks,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy
  ]
}

# Enable CloudWatch logging for EKS cluster
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/vanillatstodo-cluster/cluster"
  retention_in_days = 7

  tags = {
    Environment = "staging"
    Project     = "vanillatstodo"
    ManagedBy   = "terraform"
  }
}
