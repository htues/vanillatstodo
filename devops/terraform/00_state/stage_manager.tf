# Local variables
locals {
  bucket_name = "${var.project_name}-terraform-state"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Layer       = "state"
  }
}

# (S3 bucket resources removed)
