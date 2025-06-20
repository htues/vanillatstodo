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