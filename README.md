## Terraform Console Command

Starting config in `main.tf` defines an EC2 instance and a bucket.

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
> aws_instance.app
##...lots of data
> aws_instance.app.id
"i-058c9200aef63c0a8"
> "Instance: ${aws_instance.app.id}, AMI ID: ${aws_instance.app.ami}"
"Instance: i-058c9200aef63c0a8, AMI ID: ami-0c5204531f799e0c6"
> { instance_id: aws_instance.app.id, ami_id: aws_instance.app.ami }
{
  "ami_id" = "ami-0c5204531f799e0c6"
  "instance_id" = "i-058c9200aef63c0a8"
}
> data.aws_ami.amazon_linux
##...
```

Now use this data to create an output that collects info about the instance into a map.

```sh
> { instance_id = aws_instance.app.id, ami_id = aws_instance.app.ami, latest_ami = data.aws_ami.amazon_linux.id, is_latest_ami = aws_instance.app.ami == data.aws_ami.amazon_linux.id }
{
  "ami_id" = "ami-0c5204531f799e0c6"
  "instance_id" = "i-058c9200aef63c0a8"
  "is_latest_ami" = false
  "latest_ami" = "ami-083ac7c7ecf9bb9b0"
}
```

Exit the console with `Ctrl-D` or `exit`.

```sh
> exit
```

Add to `outputs.tf`.

```hcl
output "instance_details" {
  description = "Details about our instance."
  value = {
    instance_id = aws_instance.app.id,
    ami_id = aws_instance.app.ami,
    latest_ami = data.aws_ami.amazon_linux.id,
    is_latest_ami = (aws_instance.app.ami == data.aws_ami.amazon_linux.id)
  }
}
```

```sh
$ terraform apply
##...
Outputs:

instance_details = {
  "ami_id" = "ami-0c5204531f799e0c6"
  "instance_id" = "i-09bb818dba51253c5"
  "is_latest_ami" = false
  "latest_ami" = "ami-083ac7c7ecf9bb9b0"
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

```sh
> aws_s3_bucket.website.policy
"{\"Statement\":[{\"Action\":\"s3:GetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"arn:aws:s3:::hashilearn-etsyji4p51rg/*\",\"Sid\":\"PublicReadGetObject\"}],\"Version\":\"2012-10-17\"}"
```

Use the `jsondecode()` function to convert from JSON to HCL.

```sh
> jsondecode(aws_s3_bucket.website.policy)
{
  "Statement" = [
    {
      "Action" = "s3:GetObject"
      "Effect" = "Allow"
      "Principal" = "*"
      "Resource" = "arn:aws:s3:::hashilearn-etsyji4p51rg/*"
      "Sid" = "PublicReadGetObject"
    },
  ]
  "Version" = "2012-10-17"
}
```

Exit the console with `exit` or `Control-D`.

```
> exit
```

Remove the old `policy =<<EOF ... EOF`, copy and paste the HCL version of the
policy into the config, and replace the bucket name with `${local.bucket_name}`.
Use `jsonencode()` to convert back to JSON.

```hcl
  policy = jsonencode({
  "Statement" = [
    {
      "Action" = "s3:GetObject"
      "Effect" = "Allow"
      "Principal" = "*"
      "Resource" = "arn:aws:s3:::${local.bucket_name}/*"
      "Sid" = "PublicReadGetObject"
    },
  ]
  "Version" = "2012-10-17"
})
```

Copy website to bucket.

```sh
$ aws s3 sync www/ s3://$(terraform output -raw s3_bucket_name)
```

Refresh state to load objects into data.aws_s3_bucket_objects.website.

```sh
$ terraform refresh
```

## Goal: Echo a command to the console

If you just need to evaluate a single expression, you can "echo" a string to the console command.

```sh
$ echo "data.aws_s3_bucket_objects.website" | terraform console
{
  "bucket" = "hashilearn-o8c533b3rq71"
  "common_prefixes" = tolist([])
  "delimiter" = tostring(null)
  "encoding_type" = tostring(null)
  "fetch_owner" = tobool(null)
  "id" = "hashilearn-o8c533b3rq71"
  "keys" = tolist([
    "error.html",
    "images/background.png",
    "index.html",
    "scripts/terramino.js",
    "styles/main.css",
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
  value = data.aws_s3_bucket_objects.website.keys
}
```

Apply to see the output.

```sh
$ terraform apply
##...
s3_bucket_objects = tolist([
  "error.html",
  "images/background.png",
  "index.html",
  "scripts/terramino.js",
  "styles/main.css",
])
```

Destroy.

```sh
$ terraform destroy
```