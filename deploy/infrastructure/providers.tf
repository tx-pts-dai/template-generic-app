terraform {
  required_version = "~> 1.6.0"

  backend "s3" {
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
  region = var.region
  default_tags {
    tags = {
      "Terraform"   = "true"
      "Environment" = var.environment
      "Repository"  = var.github_repo
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  default_tags {
    tags = {
      "Terraform"   = "true"
      "Environment" = var.environment
      "Repository"  = var.github_repo
    }
  }
}

data "aws_secretsmanager_secret_version" "cloudflare_api_token" {
  secret_id = "tf_cloudflare_api_token"
}

provider "cloudflare" {
  api_token = data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    key    = "infrastructure/terraform.tfstate"
  }
}
