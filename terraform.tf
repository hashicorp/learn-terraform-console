terraform {
#   cloud {
#     organization = "YOUR ORGANIZATION"

#     workspaces {
#       name = "learn-terraform-console"
#     }
#   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.10.0"
    }
  }

  required_version = "~> 1.1"
}
