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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.environment
      Repository  = var.github_repo
      GithubOrg   = var.github_org
    }
  }
}

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
  name = data.terraform_remote_state.infra_remote.outputs.eks.cluster_name
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "infra_remote" {
  backend = "s3"
  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    key    = "@{{ infra_repo }}/platform/terraform.tfstate"
  }
}

data "terraform_remote_state" "infra_local" {
  backend = "s3"
  config = {
    bucket = "tf-state-${data.aws_caller_identity.current.account_id}"
    key    = "${var.github_repo}/infrastructure/terraform.tfstate" # Must match what's defined in `/deploy/infrastructure/providers.tf`
  }
}
