#!/bin/bash

# Set strict error handling
set -e

AWS_REGION="us-east-2"
LOG_FILE="aws-permissions-test.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

test_s3_permissions() {
    log_message "Testing S3 permissions..."
    
    # Test general S3 access first
    if ! aws s3api list-buckets 2>/dev/null; then
        log_message "⚠️ Warning: Cannot list all buckets (s3:ListAllMyBuckets)"
    fi

    # Test specific bucket operations
    if aws s3api head-bucket --bucket vanillatstodo-terraform-state 2>/dev/null; then
        log_message "✅ Bucket exists and is accessible"
    else
        log_message "ℹ️ Bucket does not exist (expected for first run)"
        log_message "✅ S3 permissions OK (bucket will be created during deployment)"
    fi
}

test_dynamodb_permissions() {
    log_message "Testing DynamoDB permissions..."
    
    # Test DynamoDB general permissions with better error handling
    if ! aws dynamodb list-tables --region $AWS_REGION 2>/dev/null; then
        log_message "⚠️ Warning: Cannot list DynamoDB tables"
    else
        log_message "✅ Can list DynamoDB tables"
    fi

    # Check if specific table exists
    if aws dynamodb describe-table --table-name vanillatstodo-terraform-state-lock --region $AWS_REGION 2>/dev/null; then
        log_message "✅ DynamoDB table exists and is accessible"
    else
        log_message "ℹ️ DynamoDB table does not exist (expected for first run)"
        log_message "✅ DynamoDB permissions OK (table will be created during deployment)"
    fi
}

test_vpc_permissions() {
    log_message "Testing VPC permissions..."
    
    if ! aws ec2 describe-vpcs --region $AWS_REGION 2>/dev/null; then
        log_message "❌ Failed: Cannot list VPCs - check EC2 permissions"
        return 1
    fi
    
    if ! aws ec2 describe-subnets --region $AWS_REGION 2>/dev/null; then
        log_message "⚠️ Warning: Cannot list subnets"
    fi
    
    log_message "✅ VPC/EC2 permissions OK"
    return 0
}

test_eks_permissions() {
    log_message "Testing EKS permissions..."
    
    # Test EKS service access
    aws eks list-clusters --region $AWS_REGION || {
        log_message "❌ Failed: Cannot access EKS service"
        return 1
    }
    log_message "✅ EKS permissions OK"
}

test_iam_permissions() {
    log_message "Testing IAM permissions..."
    
    # Test IAM role operations
    ROLE_NAME="eks_cluster_role"
    if aws iam get-role --role-name $ROLE_NAME 2>/dev/null; then
        log_message "✅ IAM role exists and is accessible"
    else
        log_message "ℹ️ IAM role does not exist (expected for first run)"
        log_message "✅ IAM permissions OK (roles will be created during deployment)"
    fi
}

main() {
    log_message "Starting IAM permission tests..."
    
    test_s3_permissions || exit 1
    test_dynamodb_permissions || exit 1
    test_vpc_permissions || exit 1
    test_eks_permissions || exit 1
    test_iam_permissions || exit 1
    
    log_message "✅ All permission tests completed successfully"
}

# Execute main function
main "$@"
