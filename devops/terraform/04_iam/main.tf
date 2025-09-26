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
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "github-actions-deployer-role"
  })
}

# Attach EKS policies to the GitHub Actions role
resource "aws_iam_role_policy_attachment" "github_actions_eks_cluster" {
  role       = aws_iam_role.github_actions_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_worker" {
  role       = aws_iam_role.github_actions_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "github_actions_eks_cni" {
  role       = aws_iam_role.github_actions_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Additional EKS permissions for deployment
resource "aws_iam_role_policy_attachment" "github_actions_eks_vpc_cni" {
  role       = aws_iam_role.github_actions_deployer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Custom policy for additional EKS operations
resource "aws_iam_role_policy" "github_actions_eks_custom" {
  name = "GitHubActionsEKSCustom"
  role = aws_iam_role.github_actions_deployer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:UpdateKubeconfig",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "iam:ListRoles",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
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
