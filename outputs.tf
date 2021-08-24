# Output values

output "s3_bucket_name" {
  description = "Name of our S3 bucket."
  value       = aws_s3_bucket.data.bucket
}

# output "bucket_details" {
#   description = "Details about our bucket."
#   value = {
#     arn = aws_s3_bucket.data.arn,
#     region = aws_s3_bucket.data.region,
#     id = aws_s3_bucket.data.id

# #    allowed_ips = jsondecode(aws_s3_bucket.data.policy).Statement[0].Condition.NotIpAddress["aws:SourceIp"]
#   }
# }
