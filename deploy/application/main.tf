locals {
  app_name     = "@{{ app_name }}"
  cluster_name = data.terraform_remote_state.infra_remote.outputs.eks.cluster_name
  namespace    = data.terraform_remote_state.infra_local.outputs.k8s_namespace
  image_repo   = data.terraform_remote_state.infra_local.outputs.ecr_repository_url
  iam_role_arn = data.terraform_remote_state.infra_local.outputs.iam_eks_role_arn
  app_url      = data.terraform_remote_state.infra_local.outputs.app_url

  target_group_name = "${var.app_name}-${local.cluster_name}"
  target_group_arn  = try(data.terraform_remote_state.infra_shared_remote.outputs.alb_target_groups[local.target_group_name].arn, "")
}

resource "helm_release" "app" {
  name             = trim(substr(local.app_name, 0, 53), "-")
  repository       = "https://dnd-it.github.io/helm-charts"
  chart            = "webapp"
  version          = "0.2.1"
  namespace        = local.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  max_history      = 3

  values = [
    templatefile("${path.module}/files/values.yaml.tpl", {
      aws_iam_role_arn            = local.iam_role_arn
      cluster_name                = local.cluster_name
      image_repo                  = local.image_repo
      image_tag                   = var.image_tag
      hostname                    = data.terraform_remote_state.infra_local.outputs.app_url
      deployment_annotations      = var.deployment_annotations
      env_vars                    = {}
      enable_target_group_binding = var.enable_target_group_binding
      target_group_arn            = local.target_group_arn
    })
  ]
}
