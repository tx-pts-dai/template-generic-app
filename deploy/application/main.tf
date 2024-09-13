locals {
  iam_role_arn = data.terraform_remote_state.infra_local.outputs.iam_eks_role_arn
  app_url      = data.terraform_remote_state.infra_local.outputs.app_url
}

data "aws_ecr_repository" "this" {
  name = var.github_repo
}

{%- if app_url_type == "path" %}

data "aws_lb_target_group" "this" {
  count = var.enable_target_group_binding ? 1 : 0

  name = "${var.app_name}-${local.cluster_name}"
}
{%- endif %}

resource "helm_release" "app" {
  name             = trim(substr(var.app_name, 0, 53), "-")
  repository       = "https://dnd-it.github.io/helm-charts"
  chart            = "webapp"
  version          = "1.1.0"
  namespace        = coalesce(var.namespace, data.terraform_remote_state.infra_local.outputs.k8s_namespace)
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  wait             = true
  max_history      = 3

  values = [
    templatefile("${path.module}/files/values.yaml.tpl", {
      aws_iam_role_arn       = local.iam_role_arn
      cluster_name           = local.cluster_name
      external_secrets       = var.external_secrets
      image_repo             = data.aws_ecr_repository.this.repository_url
      image_tag              = var.image_tag
      scaling_enabled        = var.scaling_enabled
      {%- if app_url_type == "subdomain" %}
      hostname               = data.terraform_remote_state.infra_local.outputs.app_url
      service_name           = var.app_name
      {%- endif %}
      deployment_annotations = var.deployment_annotations
      env_vars               = {}
      {%- if app_url_type == "path" %}

      enable_target_group_binding = var.enable_target_group_binding
      target_group_arn            = var.enable_target_group_binding ? data.aws_lb_target_group.this[0].arn : ""
      {%- endif %}
    })
  ]
}
