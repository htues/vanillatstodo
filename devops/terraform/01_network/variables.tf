variable "environment" {
  description = "vanillatstodoenviro"
  type        = string
  default     = "staging"

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be either 'staging' or 'production'."
  }  
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

