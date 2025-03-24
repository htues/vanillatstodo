#!/bin/bash

set -e

AWS_REGION="us-east-2"
S3_BUCKET="vanillatstodo-terraform-state"
DYNAMO_TABLE="vanillatstodo-terraform-state-lock"
LOG_FILE="terraform-deployment.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_aws_resource() {
    local resource_type=$1
    local resource_name=$2
    
    case $resource_type in
        "s3")
            aws s3api head-bucket --bucket "$resource_name" 2>/dev/null
            ;;
        "dynamodb")
            aws dynamodb describe-table --table-name "$resource_name" --region "$AWS_REGION" 2>/dev/null
            ;;
    esac
}

setup_prerequisites() {
    log_message "Setting up prerequisites..."
    
    # Check/Create S3 bucket
    if ! check_aws_resource "s3" "$S3_BUCKET"; then
        log_message "Creating S3 bucket..."
        aws s3api create-bucket \
            --bucket "$S3_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
        
        aws s3api put-bucket-versioning \
            --bucket "$S3_BUCKET" \
            --versioning-configuration Status=Enabled
    fi
    
    # Check/Create DynamoDB table
    if ! check_aws_resource "dynamodb" "$DYNAMO_TABLE"; then
        log_message "Creating DynamoDB table..."
        aws dynamodb create-table \
            --table-name "$DYNAMO_TABLE" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
            --region "$AWS_REGION"
    fi
}

clean_resources() {
    log_message "Cleaning up infrastructure..."
    
    # Clean S3 bucket if exists
    if check_aws_resource "s3" "$S3_BUCKET"; then
        log_message "Cleaning S3 bucket..."
        aws s3 rm "s3://$S3_BUCKET" --recursive
        aws s3api delete-bucket --bucket "$S3_BUCKET" --region "$AWS_REGION"
    fi
    
    # Clean DynamoDB if exists
    if check_aws_resource "dynamodb" "$DYNAMO_TABLE"; then
        log_message "Cleaning DynamoDB table..."
        aws dynamodb delete-table --table-name "$DYNAMO_TABLE" --region "$AWS_REGION"
    fi
}

main() {
    local command=$1
    
    case $command in
        "check")
            log_message "Checking infrastructure prerequisites..."
            setup_prerequisites
            ;;
        "clean")
            log_message "Cleaning up infrastructure..."
            clean_resources
            ;;
        *)
            echo "Usage: $0 {check|clean}"
            exit 1
            ;;
    esac
}

main "$@"