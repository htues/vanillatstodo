# CloudWatch Dashboard for EKS
resource "aws_cloudwatch_dashboard" "eks" {
  dashboard_name = "${var.project_name}-${var.environment}-${var.cluster_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", data.aws_eks_cluster.main.name],
            [".", "cluster_node_count", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EKS Node Count"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EKS", "cluster_request_count", "ClusterName", data.aws_eks_cluster.main.name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "API Request Count"
        }
      }
    ]
  })
}