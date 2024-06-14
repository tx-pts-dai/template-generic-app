locals {
  cluster_name   = data.terraform_remote_state.infra_remote.outputs.eks.cluster_name
  cluster_vpc_id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id

  app_name        = var.app_name
  app_url         = join(".", compact([var.app_subdomain, data.aws_route53_zone.zone.name]))
  namespace       = var.app_name # must match the namespace in the ./deploy/application/main.tf 
  service_account = var.app_name
  team_name       = var.team_name
}

resource "aws_ecr_repository" "this" {
  name                 = var.github_repo
  image_tag_mutability = "MUTABLE"

  force_delete = true
}

module "iam_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "5.32.0"

  role_name_prefix = "${var.app_name}-"

  assume_role_condition_test = "StringEquals"
  cluster_service_accounts = {
    "${local.cluster_name}" = ["${local.namespace}:${local.service_account}"]
  }

  # Create and set additional policies here
  role_policy_arns = {
    # s3 = aws_iam_policy.read_s3.arn
  }
}

{% if dns_provider == "aws" %}
data "aws_route53_zone" "this" {
  name = var.dns_zone_domain
}

{% elif dns_provider == "cloudflare" %}
data "cloudflare_zone" "this" {
  name = var.dns_zone_domain
}

{% endif %}

data "aws_subnets" "public" { # TODO: decide if we need to keep this in the template
  filter {
    name   = "vpc-id"
    values = [local.cluster_vpc_id]
  }
  tags = {
    Name = "*-public-*"
  }
}

# TODO: make this conditional?
# Certificate is picked automatically by the ALB Controller through auto-discovery
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.hostname

  {%- if dns_provider == "aws" %}
  zone_id = data.aws_route53_zone.this.zone_id

  {%- elif dns_provider == "cloudflare" %}
  create_route53_records  = false
  validation_record_fqdns = cloudflare_record.validation[*].hostname
  {%- endif %}

  validation_method = "DNS"
}


{%- if dns_provider == "cloudflare" %}
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
