terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "vanillatstodo-terraform-state"
    key            = "experimental/state/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    use_lockfile   = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = "vanillatstodo-terraform-state"
  versioning_configuration {
    status = "Enabled"
  }
} 