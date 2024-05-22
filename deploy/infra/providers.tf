terraform {
  required_version = "~> 1.5"

  backend "s3" {
    # key            = "@@github_repo@@/app/@@environment@@.tfstate"
    region         = "@@region@@"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # cloudflare = {
    #   source  = "cloudflare/cloudflare"
    #   version = "~> 4.22"
    # }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = merge(
      {
        Terraform = "true"
      },
    var.tags)
  }
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = var.platform_remote_state.bucket
    key    = var.platform_remote_state.key
    region = var.platform_remote_state.region
  }
}
