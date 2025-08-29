output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = data.aws_cloudwatch_log_group.eks.name
}

output "app_log_group_name" {
  description = "Name of the Application CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "dashboard_name" {
  description = "Name of the CloudWatch Dashboard"
  value       = aws_cloudwatch_dashboard.eks.dashboard_name
}