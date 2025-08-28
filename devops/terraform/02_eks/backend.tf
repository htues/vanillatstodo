terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "vanillatstodo-terraform-state"
    key            = "ENVIRONMENT/eks/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    use_lockfile   = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = "vanillatstodo-terraform-state"
    key     = "${var.environment}/network/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}