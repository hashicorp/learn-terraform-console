# Output values

output "s3_bucket_name" {
  description = "Name of our S3 bucket."
  value       = aws_s3_bucket.data.bucket
}

output "instance_details" {
  description = "Details about our instance."
  value = {
    instance_id   = aws_instance.app.id,
    ami_id        = aws_instance.app.ami,
    latest_ami    = data.aws_ami.amazon_linux.id,
    is_latest_ami = aws_instance.app.ami == data.aws_ami.amazon_linux.id
  }
}

output "s3_bucket_objects" {
  description = "List of objects in our bucket."
  value = data.aws_s3_bucket_objects.data_bucket.keys
}
