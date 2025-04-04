# Verify state bucket exists
data "aws_s3_bucket" "state_bucket" {
  bucket = "vanillatstodo-terraform-state"
}

# Verify DynamoDB table exists
data "aws_dynamodb_table" "state_lock" {
  name = "vanillatstodo-terraform-state-lock"
}

# Basic verification output
output "infrastructure_verification" {
  value = {
    bucket_exists = data.aws_s3_bucket.state_bucket.id != ""
    bucket_arn    = data.aws_s3_bucket.state_bucket.arn
    table_exists  = data.aws_dynamodb_table.state_lock.id != ""
    table_arn     = data.aws_dynamodb_table.state_lock.arn
  }
}