#!/bin/bash

set -e

AWS_REGION="us-east-2"
LOG_FILE="terraform-deployment.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

verify_aws_connection() {
    log_message "Verifying AWS credentials and permissions..."
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log_message "ERROR: AWS credentials not configured correctly"
        return 1
    fi
    
    # Check required permissions
    local required_services=("s3" "dynamodb" "eks" "ec2" "iam")
    for service in "${required_services[@]}"; do
        log_message "Checking $service permissions..."
        aws $service describe-account-attributes >/dev/null 2>&1 || {
            log_message "ERROR: Missing required permissions for $service"
            return 1
        }
    done
}

verify_terraform_installation() {
    log_message "Checking Terraform installation..."
    if ! terraform version >/dev/null 2>&1; then
        log_message "ERROR: Terraform not installed or not in PATH"
        return 1
    fi
}

cleanup_on_failure() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_message "ERROR: Deployment failed. Use 'terraform destroy' for cleanup"
    fi
    exit $exit_code
}

trap cleanup_on_failure EXIT

main() {
    local command=$1
    
    case $command in
        "verify")
            log_message "Running pre-deployment verifications..."
            verify_aws_connection
            verify_terraform_installation
            ;;
        *)
            echo "Usage: $0 verify"
            exit 1
            ;;
    esac
}

main "$@"