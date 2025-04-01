terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket         = "vanillatstodo-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "vanillatstodo-terraform-state-lock"
  }
}