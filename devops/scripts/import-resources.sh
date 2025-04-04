#!/bin/bash

# Get resource IDs
EKS_CLUSTER_NAME="vanillatstodo-cluster"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*vanillatstodo*" --query 'Vpcs[0].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output json)

# Import EKS resources
cd ../terraform/02_eks
terraform init
terraform import aws_eks_cluster.main $EKS_CLUSTER_NAME

# Import Network resources
cd ../01_network
terraform init
terraform import aws_vpc.main $VPC_ID