# ---------------------------------------------------------------------------
# BOOTSTRAP — creates the S3 bucket + DynamoDB table used as the remote
# backend for every other environment (dev/qa/prod).
#
# This config intentionally uses a LOCAL backend (no remote state of its
# own) because it is what CREATES the remote state infrastructure — a
# classic chicken-and-egg problem. Run this ONCE, manually, before ever
# running terraform in dev/qa/prod.
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevents accidental deletion of the bucket holding ALL environments' state
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = var.state_bucket_name
    Purpose   = "terraform-remote-state"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled" # keeps history of state file, lets you recover from a bad apply
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table used for state LOCKING — prevents two people/pipelines
# from running `terraform apply` on the same environment at the same time.
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Purpose   = "terraform-state-locking"
    ManagedBy = "terraform"
  }
}
