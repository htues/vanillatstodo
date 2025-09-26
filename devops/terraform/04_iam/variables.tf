variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "vanillatstodo"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
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

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^us-east-2$", var.aws_region))
    error_message = "Only us-east-2 is supported for this project"
  }
}

variable "github_owner" {
  description = "GitHub username or organization name"
  type        = string
  default     = "hftamayo"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "vanillatstodo"
}
