# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Output values

output "s3_bucket_name" {
  description = "Name of our S3 bucket."
  value       = aws_s3_bucket.data.bucket
}
