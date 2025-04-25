aws_region    = "us-east-2"
environment   = "staging"
cluster_name  = "vanillatstodo-cluster"
vpc_cidr      = "10.0.0.0/16"

public_subnet_cidrs = {
  a = "10.0.1.0/24"
  b = "10.0.2.0/24"
}

private_subnet_cidrs = {
  a = "10.0.3.0/24"
  b = "10.0.4.0/24"
}

vpc_flow_log_retention = 30

tags = {
  Project     = "vanillatstodo"
  ManagedBy   = "terraform"
  Environment = "staging"
}