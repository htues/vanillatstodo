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

# Reference existing CloudWatch Log Group created by EKS
data "aws_cloudwatch_log_group" "eks" {
  name = "/aws/eks/${var.cluster_name}/cluster"
}

# Create a separate log group for custom application logs if needed
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.environment}-${var.project_name}-${var.cluster_name}-app-logs"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}