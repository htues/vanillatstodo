data "aws_s3_bucket" "state_bucket" {
  bucket = "vanillatstodo-terraform-state"
}

data "aws_dynamodb_table" "state_lock" {
  name = "vanillatstodo-terraform-state-lock"
}

# Verification outputs
output "bucket_verification" {
  value = {
    exists          = data.aws_s3_bucket.state_bucket.id != ""
    versioning      = data.aws_s3_bucket.state_bucket.versioning[0].enabled
    region          = data.aws_s3_bucket.state_bucket.region
    public_blocked  = length(data.aws_s3_bucket.state_bucket.public_access_block) > 0
  }
}

output "dynamodb_verification" {
  value = {
    exists       = data.aws_dynamodb_table.state_lock.id != ""
    status       = data.aws_dynamodb_table.state_lock.table_status
    billing_mode = data.aws_dynamodb_table.state_lock.billing_mode
    hash_key     = data.aws_dynamodb_table.state_lock.hash_key
  }
}