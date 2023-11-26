provider "aws" {
  region = "eu-west-2"
}

# Uncomment after initial provisioning of resources
# terraform {
#   backend "s3" {
#     bucket         = "tf-backend-tfstate"
#     key            = "global/s3/terraform.tfstate"
#     region         = "eu-west-2"
#     dynamodb_table = "tf-backend-tfstate-lock"
#     encrypt        = true
#   }
# }

# The tfstate bucket
resource "aws_s3_bucket" "backend_bucket" {
  bucket        = "tf-backend-tfstate"
  force_destroy = true

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Turn on bucket versioning
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.backend_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.backend_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB for lock state
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tf-backend-tfstate-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
