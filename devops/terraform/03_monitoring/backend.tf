terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "vanillatstodo-terraform-state"
    key          = "ENVIRONMENT/monitoring/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket  = "vanillatstodo-terraform-state"
    key     = "${var.environment}/eks/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}