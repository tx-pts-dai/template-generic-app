locals {
  app_name     = var.app_name
  cluster_name = data.terraform_remote_state.infra_remote.outputs.eks.cluster_name
  namespace    = data.terraform_remote_state.infra_local.outputs.k8s_namespace
  image_repo   = data.terraform_remote_state.infra_local.outputs.ecr_repository_url
  iam_role_arn = data.terraform_remote_state.infra_local.outputs.iam_eks_role_arn
}

resource "helm_release" "app" {
  name             = local.app_name
  repository       = "https://dnd-it.github.io/helm-charts"
  chart            = "app"
  version          = "0.1.1"
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
      service_name           = local.app_name
      hostname               = data.terraform_remote_state.infra_local.outputs.app_url
      path                   = var.path
      node_pool              = var.node_pool
      deployment_annotations = var.deployment_annotations
      env_vars               = {}
    })
  ]
}
