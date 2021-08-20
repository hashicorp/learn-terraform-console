variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "bucket_prefix" {
  description = "Prefix for bucket name."
  type        = string
  default     = "hashilearn"
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access S3 bucket."
  type = list(string)
  default = [
    "192.0.2.1",
    "192.0.2.3",
    "192.0.2.5"
  ]
}
