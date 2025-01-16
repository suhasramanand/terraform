# Specify the AWS provider
provider "aws" {
  region = "us-west-2"
}

# Specify the Kubernetes provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.example.token
}

# Define a VPC for the Kubernetes cluster
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Define Subnets for the Kubernetes cluster
resource "aws_subnet" "eks_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}

# Define an EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.21"
  subnets         = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
  vpc_id          = aws_vpc.eks_vpc.id

  node_groups = {
    eks_node_group = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type = "t3.medium"
      key_name      = "my-ec2-key"
    }
  }
}

# Output the EKS cluster endpoint and certificate authority
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

# Define Kubernetes resources (e.g., a pod) after cluster is provisioned
resource "kubernetes_pod" "example_pod" {
  metadata {
    name = "example-pod"
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx:latest"
    }
  }
}
