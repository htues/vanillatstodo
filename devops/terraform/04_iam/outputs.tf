output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions deployment role"
  value       = aws_iam_role.github_actions_deployer.arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions deployment role"
  value       = aws_iam_role.github_actions_deployer.name
}
