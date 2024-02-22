terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.67.0"
    }
  }
  required_version = ">= 1.1"
}

provider "aws" {
  region = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}
