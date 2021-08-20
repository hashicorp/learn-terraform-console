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
    http = {
      source = "hashicorp/http"
      version = "2.1.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_string" "bucket_suffix" {
  length  = 12
  special = false
  upper   = false
}

locals {
  bucket_name = "${var.bucket_prefix}-${random_string.bucket_suffix.result}"
  local_ip_cidr = chomp(data.http.local_ip.body)
}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_s3_bucket" "data" {
  bucket = local.bucket_name

  force_destroy = true

  acl = "private"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "S3DataBucketPolicy",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${local.bucket_name}",
        "arn:aws:s3:::${local.bucket_name}/*"
      ],
      "Condition": {
        "NotIpAddress": {
          "aws:SourceIp": "${local.local_ip}"
        },
        "Bool": {"aws:ViaAWSService": "false"}
      }
    }
  ]
}
EOF
}

data "aws_s3_bucket_objects" "data_bucket" {
  bucket = aws_s3_bucket.data.bucket
}
