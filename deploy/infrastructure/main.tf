locals {
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  hostname     = var.hostname
  namespace    = var.environment
  service_name = var.github_repo
}

resource "aws_ecr_repository" "this" {
  name                 = var.github_repo
  image_tag_mutability = "IMMUTABLE"

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

  role_policy_arns = {
    # s3 = aws_iam_policy.this.arn
  }
}
