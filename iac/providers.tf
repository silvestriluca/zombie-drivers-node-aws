terraform {
  required_version = ">=1.0.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      environment  = var.environment
      service      = var.app_name_verbose
      stage        = var.stage
      repository   = var.app_repository_name
      tf-workspace = terraform.workspace
    }
  }
}
