resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.environment}-terraform-state"
    Environment = var.environment
    Layer       = "state"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Create separate logging bucket
resource "aws_s3_bucket" "terraform_state_logs" {
  bucket = "${var.project_name}-terraform-state-logs"

  tags = {
    Name        = "${var.environment}-terraform-state-logs"
    Environment = var.environment
    Layer       = "state"
    ManagedBy   = "terraform"
  }
}

# Configure logging to separate bucket
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.terraform_state_logs.id
  target_prefix = "state-bucket-logs/"
}

# Add lifecycle policy for logs
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_logs" {
  bucket = aws_s3_bucket.terraform_state_logs.id

  rule {
    id     = "cleanup_old_logs"
    status = "Enabled"

    filter {
      prefix = "state-bucket-logs/"
    }

    expiration {
      days = 90
    }
  }
}