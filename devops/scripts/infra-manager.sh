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
}

verify_s3_permissions() {
    log_message "Checking S3 permissions..."
    
    # Test general S3 access
    if ! aws s3api list-buckets >/dev/null 2>&1; then
        log_message "WARNING: Cannot list all buckets (continuing with specific checks)"
    fi

    # Check specific bucket permissions
    BUCKET_NAME="vanillatstodo-terraform-state"
    if aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null; then
        log_message "✅ S3 bucket exists and is accessible"
    else
        log_message "ℹ️ S3 bucket does not exist (will be created during deployment)"
    fi
}

ensure_s3_bucket_exists() {
    BUCKET_NAME="vanillatstodo-terraform-state"
    AWS_REGION="us-east-2"
    log_message "Ensuring S3 bucket $BUCKET_NAME exists..."
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        log_message "✅ S3 bucket $BUCKET_NAME already exists."
    else
        log_message "🪣 S3 bucket $BUCKET_NAME does not exist. Creating..."
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
        log_message "✅ S3 bucket $BUCKET_NAME created."
    fi
}

verify_prerequisites() {
    log_message "Running pre-deployment verifications..."
    
    verify_aws_connection || {
        log_message "ERROR: AWS authentication failed"
        exit 1
    }

    verify_s3_permissions || {
        log_message "WARNING: S3 checks completed with warnings"
        # Don't exit, as bucket might not exist yet
    }

    ensure_s3_bucket_exists

    log_message "✅ Prerequisites verification completed"
}

main() {
    local command=$1
    
    case $command in
        "verify")
            verify_prerequisites
            ;;
        *)
            echo "Usage: $0 verify"
            exit 1
            ;;
    esac
}

main "$@"
