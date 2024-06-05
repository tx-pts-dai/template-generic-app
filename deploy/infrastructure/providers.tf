terraform {
  required_version = "~> 1.7.0"

  backend "s3" {
    key            = "@{{ github_repo }}/infrastructure.tfstate"
    region         = "@{{ aws_region }}"
    dynamodb_table = "terraform-lock"
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

{% if dns_provider == "cloudflare" %}
data "aws_secretsmanager_secret_version" "cloudflare_api_token" {
  secret_id = "tf_cloudflare_api_token" # follows naming of existing secret in Disco
}

provider "cloudflare" {
  api_token = data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string
}
{% endif %}

provider "aws" {
  region = "@{{ aws_region }}"

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
    key    = var.terraform_remote_state_key
  }
}
