locals {
  application_name = "<APPLICATION_NAME>"
  release_name     = var.environment == "prod" ? local.application_name : "${local.application_name}-${var.environment}"
  cluster_name     = data.aws_eks_cluster.cluster.id
  namespace        = data.terraform_remote_state.infra_local.outputs.k8s_namespace
  image_repo       = data.terraform_remote_state.infra_local.outputs.ecr_repository_url
  iam_role_arn     = data.terraform_remote_state.infra_local.outputs.iam_eks_role_arn
  # downscale by default in `dev` environment over night and during the weekend
}

resource "helm_release" "this" {
  name             = local.release_name
  chart            = "https://github.com/DND-IT/app-helm-chart/archive/refs/tags/4.1.0.tar.gz"
  namespace        = local.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  max_history      = 3

  values = [
    templatefile("${path.module}/files/values.yaml.tpl", {
      aws_iam_role_arn       = local.iam_role_arn
      cluster_name           = local.cluster_name
      image_repo             = local.image_repo
      image_tag              = var.image_tag
      service_name           = local.application_name
      hostname               = var.hostname
      provisioner_group      = var.provisioner_group
      deployment_annotations = var.deployment_annotations
      env_vars               = {}
    })
  ]
}
