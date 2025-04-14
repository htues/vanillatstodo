# IAM Role for EKS
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
}

# Use data source to reference existing role
data "aws_iam_role" "eks_cluster" {
  name = "${var.environment}-${var.cluster_name}-role"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = data.terraform_remote_state.network.outputs.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  # Remove depends_on since we're using existing role
  
  tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
    ManagedBy   = "terraform"
    Version     = "1.31"
  }
}

# Security group for EKS
resource "aws_security_group" "eks_cluster" {
  name        = "${var.environment}-${var.cluster_name}-sg"
  description = "Security group for EKS cluster"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.cluster_name}-sg"
    Environment = var.environment
  }
}