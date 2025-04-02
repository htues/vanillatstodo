data "aws_s3_bucket" "state_bucket" {
  bucket = "vanillatstodo-terraform-state"
}

data "aws_s3_bucket_versioning" "state_bucket" {
  bucket = data.aws_s3_bucket.state_bucket.id
}

data "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket = data.aws_s3_bucket.state_bucket.id
}

data "aws_dynamodb_table" "state_lock" {
  name = "vanillatstodo-terraform-state-lock"
}

# Verification outputs
output "bucket_verification" {
  value = {
    exists         = data.aws_s3_bucket.state_bucket.id != ""
    versioning     = data.aws_s3_bucket_versioning.state_bucket.status == "Enabled"
    region         = data.aws_s3_bucket.state_bucket.region
    public_blocked = data.aws_s3_bucket_public_access_block.state_bucket.block_public_acls
  }
}


output "dynamodb_verification" {
  value = {
    exists       = data.aws_dynamodb_table.state_lock.id != ""
    billing_mode = data.aws_dynamodb_table.state_lock.billing_mode
    hash_key     = data.aws_dynamodb_table.state_lock.hash_key
  }
}