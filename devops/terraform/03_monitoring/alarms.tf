# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "node_count" {
  alarm_name          = "${var.project_name}-${var.cluster_name}-node-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "cluster_node_count"
  namespace           = "AWS/EKS"
  period              = "300"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "This metric monitors EKS node count"

  dimensions = {
    ClusterName = data.aws_eks_cluster.main.name
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.cluster_name}-node-count-alarm"
  })
}