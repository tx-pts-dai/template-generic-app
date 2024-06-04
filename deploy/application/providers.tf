terraform {
  required_version = "~> 1.7.0"

  backend "s3" {
    key            = "<GITHUB_REPO>/application.tfstate"
    region         = "<AWS_REGION>"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    {% if dns_provider == "cloudflare" %}
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    {% endif %}
  }
}

provider "aws" {
  region = "<AWS_REGION>"

  default_tags {
    tags = {
      "Terraform"   = "true"
      "Environment" = var.environment
      "Repository"  = var.github_repo
    }
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

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.infrastructure.outputs.cluster_name
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    key    = var.terraform_remote_state_key
  }
}

data "terraform_remote_state" "infra_local" {
  backend = "s3"
  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    key    = "${var.github_repo}/infrastructure.tfstate" # Must match what's defined in `/deploy/infrastructure/providers.tf`
  }
}
