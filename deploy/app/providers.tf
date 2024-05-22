terraform {
  required_version = "~> 1.7.0"

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
    tags = merge(
      {
        Terraform = "true"
      },
    var.tags)
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

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = var.platform_remote_state.bucket
    key    = var.platform_remote_state.key
    region = var.platform_remote_state.region
  }
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.infra_remote_state.bucket
    key    = var.infra_remote_state.key
    region = var.infra_remote_state.region
  }
}
