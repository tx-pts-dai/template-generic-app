data "aws_eks_cluster" "cluster" {
  name = local.cluster_name
}

locals {
  cluster_name = data.terraform_remote_state.platform.outputs.cluster_name
}

resource "aws_ecr_repository" "this" {
  name                 = var.ecr.repository_name
  image_tag_mutability = var.ecr.image_tag_mutability
}

module "iam_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "5.32.0"

  role_name_prefix = "${var.tags.GithubRepo}-"

  assume_role_condition_test = "StringEquals"
  cluster_service_accounts = {
    "${local.cluster_name}" = ["${var.app.namespace}:${var.app.service_account_name}"]
  }

  # Create and set additional policies here
  role_policy_arns = {
    # s3 = aws_iam_policy.read_s3.arn
  }
}

# Created in the platform by default. Overridable
data "aws_route53_zone" "this" {
  name = var.dns_zone
}

# Certificate is picked automatically by the ALB Controller through auto-discovery
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.app.url

  zone_id = data.aws_route53_zone.this.zone_id

  validation_method = "DNS"
}
