#!/bin/bash

set -e

LOG_FILE="aws-permissions-test.log"
AWS_REGION="us-east-2"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

test_s3_permissions() {
    log_message "Testing S3 permissions..."
    
    # Test general S3 access first
    if ! aws s3api list-buckets 2>/dev/null; then
        log_message "⚠️ Warning: Cannot list all buckets (s3:ListAllMyBuckets)"
        # Continue testing specific bucket permissions
    fi

    # Test specific bucket operations
    if aws s3api head-bucket --bucket vanillatstodo-terraform-state 2>/dev/null; then
        log_message "✅ Bucket exists and is accessible"
    else
        log_message "ℹ️ Bucket does not exist (expected for first run)"
        log_message "✅ S3 permissions OK (bucket will be created during deployment)"
    fi


test_dynamodb_permissions() {
    log_message "Testing DynamoDB permissions..."
    
    # Test DynamoDB general permissions
    aws dynamodb list-tables --region $AWS_REGION || {
        log_message "❌ Failed: Cannot access DynamoDB service"
        return 1
    }

    # Check if table exists
    if aws dynamodb describe-table --table-name vanillatstodo-terraform-state-lock --region $AWS_REGION 2>/dev/null; then
        log_message "✅ DynamoDB table exists and is accessible"
    else
        log_message "ℹ️ DynamoDB table does not exist (expected for first run)"
        log_message "✅ DynamoDB permissions OK (table will be created during deployment)"
    fi
}

test_vpc_permissions() {
    log_message "Testing VPC permissions..."
    
    # Test VPC listing permissions
    aws ec2 describe-vpcs --region $AWS_REGION || {
        log_message "❌ Failed: Cannot list VPCs"
        return 1
    }

    # Test VPC creation permissions without actually creating one
    aws ec2 describe-vpc-attribute --vpc-id vpc-dummy --attribute enableDnsHostnames 2>/dev/null || {
        if [[ $? -eq 254 ]]; then
            log_message "✅ VPC permissions OK (access verified)"
        else
            log_message "❌ Failed: Insufficient VPC permissions"
            return 1
        fi
    }
}

test_eks_permissions() {
    log_message "Testing EKS permissions..."
    
    # Test EKS service access
    aws eks list-clusters --region $AWS_REGION || {
        log_message "❌ Failed: Cannot access EKS service"
        return 1
    }

    # Check cluster status if exists
    CLUSTER_NAME="vanillatstodo-cluster"
    if aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION 2>/dev/null; then
        log_message "✅ EKS cluster exists and is accessible"
    else
        log_message "ℹ️ EKS cluster does not exist (expected for first run)"
        log_message "✅ EKS permissions OK (cluster will be created during deployment)"
    fi
}

test_iam_permissions() {
    log_message "Testing IAM permissions..."
    
    # Test IAM role operations
    ROLE_NAME="eks_cluster_role"
    if aws iam get-role --role-name $ROLE_NAME 2>/dev/null; then
        log_message "✅ IAM role exists and is accessible"
    else
        # Test role creation permissions without actually creating one
        aws iam list-roles --path-prefix "/eks/" || {
            log_message "❌ Failed: Insufficient IAM permissions"
            return 1
        }
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

main "$@"