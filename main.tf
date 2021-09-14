terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58.0"
    }
  }

  required_version = ">= 1.0.5"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "data" {
  bucket_prefix = var.bucket_prefix

  force_destroy = true

  acl = "private"
}

data "aws_s3_bucket_objects" "data_bucket" {
  bucket = aws_s3_bucket.data.bucket
}
