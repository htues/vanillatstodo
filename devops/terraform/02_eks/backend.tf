terraform {
  backend "s3" {}
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "vanillatstodo-terraform-state"
    key    = "staging/network.tfstate"
    region = "us-east-2"
  }
}