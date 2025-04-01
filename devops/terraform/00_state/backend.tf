terraform {
  required_version = ">= 1.0.0"
  
  backend "s3" {}  # Empty block - configuration will be provided via CLI
}