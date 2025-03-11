output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}