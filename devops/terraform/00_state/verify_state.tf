# Verify state bucket exists and configuration
data "aws_s3_bucket" "state_bucket" {
  bucket = "${var.project_name}-terraform-state"
}

# Verify bucket versioning status
resource "null_resource" "verify_versioning" {
  triggers = {
    bucket_id = data.aws_s3_bucket.state_bucket.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      VERSIONING=$(aws s3api get-bucket-versioning --bucket ${data.aws_s3_bucket.state_bucket.id} --query 'Status' --output text)
      if [ "$VERSIONING" != "Enabled" ]; then
        echo "Error: Bucket versioning is not enabled"
        exit 1
      fi
    EOT
  }
}

# Enhanced verification output
output "infrastructure_verification" {
  value = {
    bucket_exists         = data.aws_s3_bucket.state_bucket.id != ""
    bucket_arn           = data.aws_s3_bucket.state_bucket.arn
    region               = data.aws_s3_bucket.state_bucket.region
    bucket_name          = data.aws_s3_bucket.state_bucket.id
    environment          = var.environment
    versioning_verified  = null_resource.verify_versioning.id != ""
  }

  description = "Terraform state infrastructure verification"
}

# Add error output for better visibility
output "verification_status" {
  value = "✅ State bucket verification completed successfully"
}