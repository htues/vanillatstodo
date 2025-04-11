locals {
  bucket_name = "${var.project_name}-terraform-state"
}

# State infrastructure verification output
output "infrastructure_verification" {
  value = {
    bucket_name = local.bucket_name
    environment = var.environment
    region     = var.aws_region
    created_at = timestamp()
  }

  description = "State infrastructure configuration details"
}

output "verification_status" {
  value = try(
    aws_s3_bucket.terraform_state.id != "" ? 
    "✅ State bucket verified: ${local.bucket_name}" : 
    "❌ State bucket not found",
    "⚠️ State verification pending"
  )
}