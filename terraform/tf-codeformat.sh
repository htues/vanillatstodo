#!/bin/bash

case "$1" in
  "fmt")
    echo "Formatting Terraform files..."
    docker exec tfdev terraform fmt -recursive
    ;;
  "validate")
    echo "Validating Terraform configuration..."
    docker exec tfdev terraform validate
    ;;
  "init")
    echo "Initializing Terraform..."
    docker exec tfdev terraform init
    ;;
  "plan")
    echo "Planning Terraform changes..."
    docker exec tfdev terraform plan
    ;;
  "apply")
    echo "Applying Terraform changes..."
    docker exec tfdev terraform apply
    ;;
  *)
    echo "Usage: $0 {fmt|init|validate|plan|apply}"
    exit 1
    ;;
esac
