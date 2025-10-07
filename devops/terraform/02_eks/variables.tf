variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster (must be supported by AWS)"
  type        = string
  default     = "1.32"

  validation {
    condition     = can(regex("^1\\.(2[7-9]|3[0-2])$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.27 or higher. Version 1.32 is recommended for extended support."
  }
}

variable "environment" {
  description = "Environment identifier for resource tagging and naming"
  type        = string
  default     = "experimental"

  validation {
    condition     = contains(["staging", "production", "experimental"], var.environment)
    error_message = "Environment must be 'staging', 'production', or 'experimental'"
  }
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "vanillatstodo"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^us-east-2$", var.aws_region))
    error_message = "Only us-east-2 is supported for this project"
  }
}

variable "cluster_name" {
  description = "Name for the EKS cluster - used in resource naming and tagging"
  type        = string
  default     = "vanillatstodo-cluster"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "cluster_role_name" {
  description = "The name of the IAM role for the EKS cluster"
  type        = string
  default     = null

  validation {
    condition     = var.cluster_role_name == null || can(regex("^[a-zA-Z0-9_-]+$", var.cluster_role_name))
    error_message = "Cluster role name must contain only letters, numbers, hyphens, and underscores"
  }
}

variable "log_retention_days" {
  description = "Number of days to retain EKS cluster CloudWatch logs"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be one of the allowed CloudWatch values"
  }
}

# Local variable to compute the cluster role name based on environment
locals {
  # Map experimental to staging role (as per your workflow logic)
  effective_environment = var.environment == "experimental" ? "staging" : var.environment

  # Compute cluster role name if not explicitly provided
  computed_cluster_role_name = var.cluster_role_name != null ? var.cluster_role_name : "${local.effective_environment}-${var.project_name}-cluster-role"
}

variable "gha_actions_role_arn" {
  description = "Optional: GitHub Actions IAM Role ARN to grant EKS admin access via Access Entries"
  type        = string
  default     = null

  validation {
    condition     = var.gha_actions_role_arn == null || can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.gha_actions_role_arn))
    error_message = "If provided, gha_actions_role_arn must be a valid IAM role ARN."
  }
}

variable "enable_ebs_csi_addon" {
  description = "Whether to deploy the EBS CSI driver as an EKS managed add-on."
  type        = bool
  default     = false
}