locals {
  namespace    = var.environment # must match the namespace in the ./deploy/application/main.tf 
  service_name = "<APPLICATION_NAME>"
  matching_index   = [for idx, name in data.aws_ssm_parameters_by_path.platform.names : idx if can(regex("^.*/cluster_name$", name))] 
  first_index      = element(local.matching_index, 0)
  cluster_name     = element(data.aws_ssm_parameters_by_path.platform.values, local.first_index)
}

resource "aws_ecr_repository" "this" {
  name                 = var.github_repo
  image_tag_mutability = "MUTABLE"

  force_delete = true
}

module "iam_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "5.32.0"

  role_name_prefix = "${var.github_repo}-"

  assume_role_condition_test = "StringLike"
  cluster_service_accounts = {
    "${local.cluster_name}" = ["${local.namespace}:${local.service_name}"]
  }

  # Create and set additional policies here
  role_policy_arns = {
    # s3 = aws_iam_policy.read_s3.arn
  }
}

# Created in the platform by default. Overridable
data "aws_route53_zone" "this" {
  name = var.dns_zone_domain
}

# Certificate is picked automatically by the ALB Controller through auto-discovery
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.hostname
  zone_id     = data.aws_route53_zone.this.zone_id

  validation_method = "DNS"
}

data "aws_ssm_parameters_by_path" "platform" {
  path = "/platform/" 
  recursive = true
}

data "aws_eks_cluster" "eks_cluster" {
  name = local.cluster_name
}
