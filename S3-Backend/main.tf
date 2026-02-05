terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "my-terraform-state-bucket-kiran"
    key = "Dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "s3_backend" {
   bucket = "my-terraform-state-bucket-kiran123" 
   tags = { 
    Name = "Terraform State Bucket" 
    Environment = "Dev" 
   }
   }