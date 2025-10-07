# GitHub OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]

  tags = merge(local.common_tags, {
    Name = "github-actions-oidc-provider"
  })
}

# IAM Role for GitHub Actions deployment
resource "aws_iam_role" "github_actions_deployer" {
  name = "${var.environment}-${var.project_name}-deployer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:htues/vanillatstodo:*"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "github-actions-deployer-role"
  })
}

# Attach EKS managed policies to the GitHub Actions role
locals {
  eks_policies = jsondecode(file("${path.module}/aws_policies/eks-managed-policies.json"))
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_policies" {
  for_each = {
    for policy in local.eks_policies.policies : policy.name => policy
  }

  role       = aws_iam_role.github_actions_deployer.name
  policy_arn = each.value.arn
}

# Custom policy for comprehensive deployment operations
resource "aws_iam_role_policy" "github_actions_deployer_custom" {
  name = "GitHubActionsDeployerCustom"
  role = aws_iam_role.github_actions_deployer.id

  policy = file("${path.module}/aws_policies/github-actions-deployer-policy.json")
}

# Local variables
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Layer       = "iam"
  }
}
