terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>5.0"
        }
    }
}

# Run with: $env:AWS_PROFILE = "account-b" before terraform commands

provider "aws" {
    region = "ap-south-1"
}