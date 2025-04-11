terraform {
  backend "s3" {
    bucket  = "vanillatstodo-terraform-state"
    key     = "staging/eks.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "vanillatstodo-terraform-state"
    key    = "staging/network.tfstate"
    region = "us-east-2"
  }
}