# Basic Terraform code to set up a cloud infrastructure

# Specify the provider (e.g., AWS, Azure, GCP)
provider "aws" {
  region = "us-east-1"
}

# Define a resource group (e.g., an S3 bucket for AWS)
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-name"
  acl    = "private"

  tags = {
    Name        = "My s3 bucket"
    Environment = "Dev"
  }

  # Enable server-side encryption
  server_side_encryption_configuration {
    rule {
      # Use AES-256 encryption
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
