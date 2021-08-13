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

resource "random_string" "bucket_suffix" {
  length  = 12
  special = false
  upper   = false
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  instance_type = "t2.micro"
  ami           = "ami-0c5204531f799e0c6"
}

locals {
  bucket_name = "${var.bucket_prefix}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name

  force_destroy = true

  acl    = "public-read"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}/*"
            ]
        }
    ]
}
EOF

#   policy = jsonencode({
#   "Statement" = [
#     {
#       "Action" = "s3:GetObject"
#       "Effect" = "Allow"
#       "Principal" = "*"
#       "Resource" = "arn:aws:s3:::${local.bucket_name}/*"
#       "Sid" = "PublicReadGetObject"
#     },
#   ]
#   "Version" = "2012-10-17"
# })

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

data "aws_s3_bucket_objects" "website" {
  bucket = aws_s3_bucket.website.bucket
}
