# Data sources for VPC and Subnets
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "cluster_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# CloudWatch Log Group for EKS
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Project     = "vanillatstodo"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "${var.environment}-${var.cluster_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-${var.cluster_name}-role"
  }
}

# IAM Role Policies for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.environment}-${var.cluster_name}-sg"
  description = "Security group for EKS cluster"
  vpc_id      = data.aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.cluster_name}-sg"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = data.aws_subnets.cluster_subnets.ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "15m"
  }

  depends_on = [
    aws_cloudwatch_log_group.eks,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy
  ]

  tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
  }
}

# Node Group Configuration
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-standard-workers"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = data.aws_subnets.cluster_subnets.ids
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-node-group"
    Environment = var.environment
  }

  # Ensure proper dependencies
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy
  ]
}

# ... existing IAM roles and policy attachments ...