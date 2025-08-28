variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "vanillatstodo-cluster"
}

variable "environment" {
  description = "Environment name"
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
  description = "AWS region"
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^us-east-2$", var.aws_region))
    error_message = "Only us-east-2 is supported for this project"
  }
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be one of the allowed CloudWatch values"
  }
}