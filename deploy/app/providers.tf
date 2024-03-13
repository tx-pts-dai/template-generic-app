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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    # What are the normal default labels used in other repos?
    tags = {
      "Terraform"   = "true"
      "Environment" = var.environment
      "Repository"  = var.github_repo
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.infrastructure.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.infrastructure.outputs.cluster_name
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    key    = "infrastructure/terraform.tfstate"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "terraform_remote_state" "infra_local" {
  backend = "s3"
  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    key    = "${var.github_repo}/infra.tfstate"
  }
}
