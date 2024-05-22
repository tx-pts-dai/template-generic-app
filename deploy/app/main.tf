locals {
  app_name     = "@@application_name@@"
  cluster_name = data.aws_eks_cluster.cluster.id
  image_repo   = data.terraform_remote_state.infra.outputs.ecr_repository_url
  iam_role_arn = data.terraform_remote_state.infra.outputs.iam_eks_role_arn
}

resource "helm_release" "this" {
  name             = local.app_name
  repository       = "https://dnd-it.github.io/helm-charts"
  chart            = "app"
  version          = "1.0.0"
  namespace        = coalesce(var.app.namespace, local.app_name)
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  max_history      = 3

  values = [
    file("${path.module}/files/values.yaml")
  ]

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "image.repository"
    value = data.terraform_remote_state.infra.outputs.ecr_repository_url
  }

  set {
    name  = "aws_iam_role_arn"
    value = local.iam_role_arn
  }

  set {
    name  = "env_vars"
    value = jsonencode(var.env_vars)
  }
}
