# Use data source to reference existing role
data "aws_iam_role" "eks_cluster" {
  name = local.computed_cluster_role_name
}

# Local variables
locals {
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  private_subnets = data.terraform_remote_state.network.outputs.private_subnet_ids
  public_subnets  = data.terraform_remote_state.network.outputs.public_subnet_ids
  all_subnets     = concat(local.private_subnets, local.public_subnets)

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Layer       = "eks"
  }
}

# Security group for EKS
resource "aws_security_group" "eks_cluster" {
  name        = "${var.environment}-${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project_name}-${var.cluster_name}-sg"
  })
}

# EKS Cluster configuration
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = local.all_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  tags = merge(local.common_tags, {
    Name    = "${var.environment}-${var.project_name}-${var.cluster_name}"
    Version = "1.31"
  })
}

# IAM role for EKS Node Group
data "aws_iam_role" "eks_nodegroup" {
  name = "${var.environment}-eks-nodegroup-role"
}

# EKS Node Group
resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "workers"
  node_role_arn   = data.aws_iam_role.eks_nodegroup.arn
  subnet_ids      = local.private_subnets

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.main,
  ]

  tags = merge(local.common_tags, {
    Name = "${var.environment}-${var.project_name}-workers"
  })
}