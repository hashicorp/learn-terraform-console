# Output values

output "bucket_details" {
  description = "Details about our bucket."
  value = {
    arn = aws_s3_bucket.data.arn,
    region = aws_s3_bucket.data.region,
    id = aws_s3_bucket.data.id
  }
}
