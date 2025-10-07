# Use data source to reference existing role
data "aws_iam_role" "eks_cluster" {
  name = "eks_cluster_role"
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

  # Enable modern EKS authentication via API while maintaining ConfigMap compatibility
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = merge(local.common_tags, {
    Name    = "${var.environment}-${var.project_name}-${var.cluster_name}"
    Version = "1.31"
  })
}

# IAM role for EKS Node Group
data "aws_iam_role" "eks_nodegroup" {
  name = "eks_node_role"
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

# Optional: Grant GitHub Actions role cluster-admin via EKS Access Entries (preferred over aws-auth alone)
resource "aws_eks_access_entry" "gha_pipeline" {
  count         = var.gha_actions_role_arn == null ? 0 : 1
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.gha_actions_role_arn
  type          = "STANDARD"

  tags = merge(local.common_tags, { Name = "gha-access-entry" })
}

resource "aws_eks_access_policy_association" "gha_admin" {
  count         = var.gha_actions_role_arn == null ? 0 : 1
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.gha_actions_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.gha_pipeline]
}

# Ensure IAM OIDC provider for the cluster exists (for IRSA)
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.main.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.main.name
}

data "tls_certificate" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]

  tags = merge(local.common_tags, { Name = "eks-oidc" })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ebs_csi" {
  name = "${var.environment}-${var.project_name}-ebs-csi-role"
  # Allow adopting a pre-existing role if it exists
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [assume_role_policy, tags]
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = [
              "system:serviceaccount:kube-system:ebs-csi-controller-sa",
              "system:serviceaccount:kube-system:ebs-csi-controller"
            ]
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, { Name = "ebs-csi-role" })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Manage EBS CSI as an EKS add-on
resource "aws_eks_addon" "ebs_csi" {
  count                       = var.enable_ebs_csi_addon ? 1 : 0
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi.arn
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(local.common_tags, { Name = "aws-ebs-csi-driver" })

  # Ensure nodes are ready before installing the daemonset-based add-on
  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi,
    aws_eks_node_group.workers,
  ]

  timeouts {
    create = "10m"
    update = "10m"
    delete = "20m"
  }
}