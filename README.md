## Terraform Console Command

Starting config in `main.tf` defines an EC2 instance, a bucket, and an IAM role
that allows the EC2 instance to read the contents of the bucket.

Init.

```sh
$ terraform init
```

Apply.

```sh
$ terraform apply
```

## Goal: Learn how to launch the console, and what it is.

```sh
$ terraform console
```

The console:

- An interactive session that evaluates Terraform expressions.
- Try out Terraform expressions before using them in configuration.
- Also loads your state when it starts, so you can explore data about your resources.

The console does not:

- Plan or apply changes
- Define new resources, data sources, or other blocks
- Modify your state

Also, it locks the state file, so you must exit the console before running other commands like plan or apply.

## Goal: Learn to evaluate expressions and call functions

```sh
> 5 + 3
8
> "Hello, world!"
"Hello, world!"
> ["zero", "one", "two"]
[
  "zero",
  "one",
  "two",
]
> sort(["zero", "one", "two"])
tolist([
  "one",
  "two",
  "zero",
])
```

## Goal: Learn how to inspect state

```sh
> aws_s3_bucket.data
##...lots of data
> aws_s3_bucket.data.arn
"arn:aws:s3:::hashilearn-gfvtd49xi10y"
> "Bucket ARN: ${aws_s3_bucket.data.arn}, Region: ${aws_s3_bucket.data.region}"
"Bucket ARN: arn:aws:s3:::hashilearn-gfvtd49xi10y, Region: us-west-2"
> { arn = aws_s3_bucket.data.arn, region = aws_s3_bucket.data.region, id = aws_s3_bucket.data.id }
{
  "arn" = "arn:aws:s3:::hashilearn-gfvtd49xi10y"
  "id" = "hashilearn-gfvtd49xi10y"
  "region" = "us-west-2"
}
```

Now use this data to create an output that collects info about the instance into a map.

```sh
> { arn = aws_s3_bucket.data.arn, region = aws_s3_bucket.data.region, id = aws_s3_bucket.data.id }
{
  "arn" = "arn:aws:s3:::hashilearn-gfvtd49xi10y"
  "id" = "hashilearn-gfvtd49xi10y"
  "region" = "us-west-2"
}
```

Exit the console with `<Ctrl-D>` or `exit`.

```sh
> exit
```

Add to `outputs.tf`.

```hcl
output "bucket_details" {
  description = "Details about our bucket."
  value = {
    arn = aws_s3_bucket.data.arn,
    region = aws_s3_bucket.data.region,
    id = aws_s3_bucket.data.id
  }
}
```

```sh
$ terraform apply
##...
Outputs:

bucket_details = {
## FIXME
}
```

## Goal: Use a function with the console

The bucket policy in the config is a multiline JSON string. You can convert
between JSON and HCL with `jsonencode()/jsondecode()`. Using HCL instead of a
JSON string can make it easier to format and catch syntax errors early.

Inspect the bucket policy.

```sh
$ terraform console
```

Use the `jsondecode()` function to convert from JSON to HCL.

```sh
> jsondecode(aws_s3_bucket.data.policy)
{
  "Id" = "S3DataBucketPolicy"
  "Statement" = [
    {
      "Action" = "s3:*"
      "Condition" = {
        "Bool" = {
          "aws:ViaAWSService" = "false"
        }
        "NotIpAddress" = {
          "aws:SourceIp" = "162.233.171.126/32"
        }
      }
      "Effect" = "Deny"
      "Principal" = "*"
      "Resource" = [
        "arn:aws:s3:::hashilearn-gfvtd49xi10y",
        "arn:aws:s3:::hashilearn-gfvtd49xi10y/*",
      ]
      "Sid" = "IPAllow"
    },
  ]
  "Version" = "2012-10-17"
}
```

Exit the console with `exit` or `Control-D`.

```shell-session
> exit
```

Remove the old `policy =<<EOF ... EOF`, copy and paste the HCL version of the
policy into the config, and replace the bucket name with `${local.bucket_name}`.
Use `jsonencode()` to convert back to JSON.

```hcl
  policy = jsonencode({
  "Id" = "S3DataBucketPolicy"
  "Statement" = [
    {
      "Action" = "s3:*"
      "Condition" = {
        "Bool" = {
          "aws:ViaAWSService" = "false"
        }
        "NotIpAddress" = {
          "aws:SourceIp" = "162.233.171.126/32"
        }
      }
      "Effect" = "Deny"
      "Principal" = "*"
      "Resource" = [
        "arn:aws:s3:::hashilearn-gfvtd49xi10y",
        "arn:aws:s3:::hashilearn-gfvtd49xi10y/*",
      ]
      "Sid" = "IPAllow"
    },
  ]
  "Version" = "2012-10-17"
})
```

Copy data to bucket.

```sh
$ aws s3 sync data/ s3://$(terraform output -raw s3_bucket_name)
```

Refresh state to load objects into data.aws_s3_bucket_objects.data.

```sh
$ terraform refresh
```

## Goal: Echo a command to the console

If you just need to evaluate a single expression, you can "echo" a string to the console command.

```sh
$ echo "data.aws_s3_bucket_objects.data_bucket" | terraform console
{
  "bucket" = "hashilearn-o8c533b3rq71"
  "common_prefixes" = tolist([])
  "delimiter" = tostring(null)
  "encoding_type" = tostring(null)
  "fetch_owner" = tobool(null)
  "id" = "hashilearn-o8c533b3rq71"
  "keys" = tolist([
    "2021-08-01.csv",
    "2021-08-02.csv",
    "2021-08-03.csv",
    "2021-08-04.csv",
    "2021-08-05.csv",
    "2021-08-06.csv",
  ])
  "max_keys" = 1000
  "owners" = tolist([])
  "prefix" = tostring(null)
  "start_after" = tostring(null)
}
```

Add an output for the list of keys.

```hcl
output "s3_bucket_objects" {
  description = "List of objects in our bucket."
  value = data.aws_s3_bucket_objects.data_bucket.keys
}
```

Apply to see the output.

```sh
$ terraform apply
##...
s3_bucket_objects = tolist([
  "2021-08-01.csv",
  "2021-08-02.csv",
  "2021-08-03.csv",
  "2021-08-04.csv",
  "2021-08-05.csv",
  "2021-08-06.csv",
])
```

Destroy.

```sh
$ terraform destroy
```