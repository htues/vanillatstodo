terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "vanillatstodo-terraform-state"
    key            = "staging/eks.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "vanillatstodo-terraform-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}