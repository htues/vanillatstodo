terraform {
  backend "s3" {}
}

data "terraform_remote_state" "eks" {
  backend   = "s3"
  workspace = "staging"
  config = {
    bucket  = "vanillatstodo-terraform-state"
    key     = "staging/eks.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}