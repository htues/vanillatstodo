variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster (must be supported by AWS)"
  type        = string
  default     = "1.27"

  validation {
    condition     = can(regex("^1\\.(2[3-7])$", var.kubernetes_version))
    error_message = "Kubernetes version must be between 1.23 and 1.27"
  }
}

variable "environment" {
  description = "Environment identifier for resource tagging and naming"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be 'staging' or 'production'"
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

variable "log_retention_days" {
  description = "Number of days to retain EKS cluster CloudWatch logs"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be one of the allowed CloudWatch values"
  }
}