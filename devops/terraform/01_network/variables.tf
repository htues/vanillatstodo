variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^us-east-2$", var.aws_region))
    error_message = "Only us-east-2 is supported for this project."
  }
}

variable "environment" {
  description = "Environment name for the infrastructure"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "production", "experimental"], var.environment)
    error_message = "Environment must be either 'staging', 'production', or 'experimental'."
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

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "vanillatstodo-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = map(string)
  default = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }

  validation {
    condition     = alltrue([for cidr in values(var.public_subnet_cidrs) : can(cidrhost(cidr, 0))])
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = map(string)
  default = {
    a = "10.0.3.0/24"
    b = "10.0.4.0/24"
  }

  validation {
    condition     = alltrue([for cidr in values(var.private_subnet_cidrs) : can(cidrhost(cidr, 0))])
    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "vpc_flow_log_retention" {
  description = "Number of days to retain VPC flow logs"
  type        = number
  default     = 30

  validation {
    condition     = var.vpc_flow_log_retention >= 1 && var.vpc_flow_log_retention <= 365
    error_message = "VPC flow log retention must be between 1 and 365 days."
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "vanillatstodo"
    ManagedBy   = "terraform"
    Environment = "staging"
  }
}

variable "enable_dns" {
  description = "Enable DNS support and DNS hostnames in VPC"
  type        = bool
  default     = true
}
