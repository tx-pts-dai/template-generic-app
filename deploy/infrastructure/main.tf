locals {
  app_name = var.app_name

  {%- if app_url_type == "subdomain" %}

  app_url = join(".", compact([var.app_subdomain, var.zone_name]))
  {%- endif %}

  namespace       = var.app_name # must match the namespace in the ./deploy/application/main.tf
  service_account = var.app_name
}

module "platform_ssm" {
  source  = "tx-pts-dai/kubernetes-platform/aws//modules/ssm"
  version = "0.7.0"

  base_prefix       = "infrastructure"
  stack_type        = "platform"
  stack_name_prefix = ""

  lookup = ["cluster_name"]
}

resource "aws_ecr_repository" "this" {
  name                 = var.github_repo
  image_tag_mutability = "MUTABLE"

  force_delete = true
}

resource "aws_iam_policy" "get_all_secrets" {
  name        = "GetAllSecretsPolicy"
  description = "Policy to allow getting all secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:eu-central-1:${data.aws_caller_identity.current.account_id}:secret:discovery/ai-tools/*"
      }
    ]
  })
}

module "iam_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "5.32.0"

  role_name_prefix = "${local.app_name}-"

  assume_role_condition_test = "StringLike"
  cluster_service_accounts = {
    for stack in module.platform_ssm.lookup : stack.cluster_name =>
    ["${local.namespace}*:${local.service_account}"]
  }

  # Create and set additional policies here
  role_policy_arns = {
    get_all_secrets = aws_iam_policy.get_all_secrets.arn
    # s3 = aws_iam_policy.read_s3.arn
  }
}

{% if dns_provider == "aws" %}
data "aws_route53_zone" "this" {
  name = var.zone_name
}

{% elif dns_provider == "cloudflare" %}
data "cloudflare_zone" "this" {
  name = var.zone_name
}
{% endif %}

{% if app_url_type == "subdomain" %}
# Certificate is picked automatically by the ALB Controller through auto-discovery
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = local.app_url

{% if dns_provider == "aws" %}
  zone_id = data.aws_route53_zone.this.zone_id
{% elif dns_provider == "cloudflare" %}
  create_route53_records  = false
  validation_record_fqdns = cloudflare_record.validation[*].hostname
{% endif %}

  validation_method = "DNS"
}
{% endif %}

{%- if dns_provider == "cloudflare" and app_url_type == "subdomain" %}
resource "cloudflare_record" "validation" {
  count = length(module.acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.this.id
  name    = element(module.acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.acm.validation_domains, count.index)["resource_record_type"]
  value   = trimsuffix(element(module.acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}
{% endif %}
