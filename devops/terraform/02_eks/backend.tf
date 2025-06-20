terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "vanillatstodo-terraform-state"
    key            = "experimental/eks/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    use_lockfile   = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = "vanillatstodo-terraform-state"
    key     = "staging/network.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}