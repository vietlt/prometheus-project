terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

// Define the region to create resources
provider "aws" {
  region = var.aws_region

}