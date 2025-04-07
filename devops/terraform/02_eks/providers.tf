terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "vanillatstodo-terraform-state"
    key            = "staging/eks.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "vanillatstodo-terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "vanillatstodo"
      ManagedBy   = "terraform"
    }
  }
}