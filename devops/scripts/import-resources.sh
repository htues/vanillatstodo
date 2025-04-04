#!/bin/bash

# Set base directory
REPO_ROOT=$(pwd)
echo "Current working directory: $REPO_ROOT"

# Get resource IDs
EKS_CLUSTER_NAME="vanillatstodo-cluster"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*vanillatstodo*" --query 'Vpcs[0].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output json)

# Import EKS resources
cd "$REPO_ROOT/devops/terraform/02_eks"
echo "Importing EKS resources from: $(pwd)"
terraform init
terraform import aws_eks_cluster.main $EKS_CLUSTER_NAME

# Import Network resources
cd "$REPO_ROOT/devops/terraform/01_network"
echo "Importing Network resources from: $(pwd)"
terraform init
terraform import aws_vpc.main $VPC_ID