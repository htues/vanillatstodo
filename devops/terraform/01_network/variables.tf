variable "environment" {
  description = "Environment name for the infrastructure (staging or production)"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be either 'staging' or 'production'."
  }
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^us-east-2$", var.aws_region))
    error_message = "Only us-east-2 is supported for this project."
  }
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

variable "subnet_cidrs" {
  description = "CIDR blocks for the subnets"
  type        = map(string)
  default = {
    subnet_a = "10.0.1.0/24"
    subnet_b = "10.0.2.0/24"
  }

  validation {
    condition     = alltrue([for cidr in values(var.subnet_cidrs) : can(cidrhost(cidr, 0))])
    error_message = "All subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "enable_dns" {
  description = "Enable DNS support and DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "vanillatstodo-cluster"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "Cluster name must consist of lower case alphanumeric characters and hyphens only."
  }
}