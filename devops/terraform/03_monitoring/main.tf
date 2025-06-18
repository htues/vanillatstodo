# Reference existing EKS cluster
data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

# Local variables
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Layer       = "monitoring"
  }
}

# CloudWatch Log Group for EKS
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.cluster_name}-logs"
  })

  # Prevent recreation of existing log group
  lifecycle {
    prevent_destroy = true
  }
}