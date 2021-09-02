terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.53.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "random_string" "bucket_suffix" {
  length  = 12
  special = false
  upper   = false
}

locals {
  bucket_name = "${var.bucket_prefix}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket" "data" {
  bucket = local.bucket_name

  force_destroy = true

  acl = "private"
}

data "aws_s3_bucket_objects" "data_bucket" {
  bucket = aws_s3_bucket.data.bucket
}
