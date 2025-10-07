terraform {
  backend "s3" {
    bucket         = "vanillatstodo-terraform-state"
    key            = "iam/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "vanillatstodo-terraform-locks"
  }
}
