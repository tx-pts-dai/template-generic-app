locals {
  region = "@{{ aws_region }}"
}

terraform {
  required_version = "~> 1.7.0"

  backend "s3" {
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    {%- if dns_provider == "cloudflare" %}
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    {%- endif %}
  }
}

{%- if dns_provider == "cloudflare" %}
data "aws_secretsmanager_secret_version" "cloudflare_api_token" {
  secret_id = "dai/cloudflare/apiToken"
}

provider "cloudflare" {
  api_token = data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string
}
{%- endif %}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.environment
      GithubRepo  = var.github_repo
      GithubOrg   = var.github_org
    }
  }
}

data "aws_caller_identity" "current" {}
