# Remote state — points at the bucket/table created by environments/bootstrap.
# Each environment uses its own "key" so state files never collide.
terraform {
  backend "s3" {
    bucket         = "myapp-terraform-state-bucket"   # must match bootstrap's state_bucket_name
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "myapp-terraform-locks"
    encrypt        = true
  }
}

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
