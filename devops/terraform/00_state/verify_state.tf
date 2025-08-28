# State infrastructure verification output
output "infrastructure_verification" {
  value = {
    bucket_name = local.bucket_name
    environment = var.environment
    region      = var.aws_region
    created_at  = timestamp()
  }

  description = "State infrastructure configuration details"
}