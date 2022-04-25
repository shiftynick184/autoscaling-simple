### TERRAFORM ###
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
  }
}

### AWS ###
provider "aws" {
  region  = "us-east-1"
  version = "3.61.0"
}