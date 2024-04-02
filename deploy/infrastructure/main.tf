locals {
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  namespace    = var.environment # must match the namespace in the ./deploy/application/main.tf 
  service_name = "<APPLICATION_NAME>"
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
