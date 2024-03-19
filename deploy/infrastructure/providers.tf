terraform {
  required_version = "~> 1.7.0"

  backend "s3" {
    key            = "<GITHUB_REPO>/infrastructure.tfstate"
    region         = "<AWS_REGION>"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.22"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      "Terraform"   = "true"
      "Environment" = var.environment
      "Repository"  = var.github_repo
    }
  }
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    key    = "infrastructure/terraform.tfstate"
  }
}
