# Verify state bucket exists
data "aws_s3_bucket" "state_bucket" {
  bucket = "${var.project_name}-terraform-state"
}

data "aws_s3_bucket_versioning" "state_bucket" {
  bucket = data.aws_s3_bucket.state_bucket.id
}

# Basic verification output
output "infrastructure_verification" {
  value = {
    bucket_exists = data.aws_s3_bucket.state_bucket.id != ""
    bucket_arn    = data.aws_s3_bucket.state_bucket.arn
    region        = data.aws_s3_bucket.state_bucket.region
    environment   = var.environment
  }

  description = "State infrastructure verification details"
}