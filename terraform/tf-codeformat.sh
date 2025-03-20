#!/bin/bash

case "$1" in
  "fmt")
    docker exec tf-dev terraform fmt -recursive
    ;;
  "validate")
    docker exec tf-dev terraform validate
    ;;
  "plan")
    docker exec tf-dev terraform plan
    ;;
  *)
    echo "Usage: $0 {fmt|validate|plan}"
    exit 1
    ;;
esac
