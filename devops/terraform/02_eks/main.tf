# Use data source to reference existing role
data "aws_iam_role" "eks_cluster" {
  name = "${var.environment}-${var.cluster_name}-role"
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
  name        = "${var.project_name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.cluster_name}-sg"
  })
}

# EKS Cluster configuration
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

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-${var.cluster_name}"
    Version = "1.31"
  })
}