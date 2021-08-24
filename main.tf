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
      source  = "hashicorp/http"
      version = "2.1.0"
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
  # local_ip = chomp(data.http.local_ip.body)
  # allowed_ips = concat([local.local_ip], var.allowed_ips)
}

resource "aws_s3_bucket" "data" {
  bucket = local.bucket_name

  force_destroy = true

  acl = "private"
}

# resource "aws_s3_bucket_policy" "private" {
#   bucket = aws_s3_bucket.data.id

#   policy = jsonencode({
#   "Id" = "S3DataBucketPolicy"
#   "Statement" = [
#     {
#       "Action" = "s3:*"
#       "Condition" = {
#         "NotIpAddress" = {
#           "aws:SourceIp" = local.local_ip
# #          "aws:SourceIp" = local.allowed_ips
#         }
#       }
#       "Effect" = "Deny"
#       "Principal" = "*"
#       "Resource" = [
#         aws_s3_bucket.data.arn,
#         "${aws_s3_bucket.data.arn}/*",
#       ]
#       "Sid" = "IPAllow"
#     },
#   ]
#   "Version" = "2012-10-17"
# })
# }

data "aws_s3_bucket_objects" "data_bucket" {
  bucket = aws_s3_bucket.data.bucket
}
