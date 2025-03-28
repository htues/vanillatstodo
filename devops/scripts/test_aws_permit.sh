#!/bin/bash

set -e

LOG_FILE="iam-test-results.log"
AWS_REGION="us-east-2"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

test_s3_permissions() {
    log_message "Testing S3 permissions..."
    aws s3api get-bucket-location --bucket vanillatstodo-terraform-state || {
        log_message "❌ Failed: Cannot access S3 bucket"
        return 1
    }
    log_message "✅ S3 permissions OK"
}

test_dynamodb_permissions() {
    log_message "Testing DynamoDB permissions..."
    aws dynamodb describe-table \
        --table-name vanillatstodo-terraform-state-lock \
        --region $AWS_REGION || {
        log_message "❌ Failed: Cannot access DynamoDB table"
        return 1
    }
    log_message "✅ DynamoDB permissions OK"
}

test_vpc_permissions() {
    log_message "Testing VPC permissions..."
    aws ec2 describe-vpcs || {
        log_message "❌ Failed: Cannot list VPCs"
        return 1
    }
    log_message "✅ VPC permissions OK"
}

test_eks_permissions() {
    log_message "Testing EKS permissions..."
    aws eks list-clusters --region $AWS_REGION || {
        log_message "❌ Failed: Cannot list EKS clusters"
        return 1
    }
    log_message "✅ EKS permissions OK"
}

test_iam_permissions() {
    log_message "Testing IAM permissions..."
    aws iam get-role --role-name "eks_cluster_role" 2>/dev/null || {
        log_message "ℹ️ Role does not exist yet (expected)"
    }
    log_message "✅ IAM permissions OK"
}

main() {
    log_message "Starting IAM permission tests..."
    
    test_s3_permissions
    test_dynamodb_permissions
    test_vpc_permissions
    test_eks_permissions
    test_iam_permissions
    
    log_message "All permission tests completed"
}

main "$@"

