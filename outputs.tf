# Output values

output "s3_bucket_name" {
  description = "Name of our S3 bucket."
  value       = aws_s3_bucket.data.bucket
}
