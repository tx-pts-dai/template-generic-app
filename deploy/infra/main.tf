locals {
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  hostname     = var.hostname
  zone_name    = "CLOUDFLARE/ROUTE53_ZONE_NAME"
  fqdn         = "${local.hostname}.${local.zone_name}"
}

resource "aws_ecr_repository" "this" {
  name                 = var.github_repo
  image_tag_mutability = "IMMUTABLE"
}

module "iam_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "5.32.0"

  role_name_prefix = "${var.github_repo}-"

  assume_role_condition_test = "StringLike"
  cluster_service_accounts = {
    "${local.cluster_name}" = ["fuw-factsheets*:*"]
  }
  role_policy_arns = {
    s3 = aws_iam_policy.this.arn
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "S3ReadWrite"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
  }

  statement {
    sid = "S3List"
    actions = [
      "s3:ListBucket",
    ]
    resources = [module.s3_bucket.s3_bucket_arn]
  }

  statement {
    sid = "EcrPull"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "this" {
  name_prefix = "${var.github_repo}-"
  description = "Provides app permissions to read and write to S3 bucket"
  policy      = data.aws_iam_policy_document.this.json
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket_prefix = "${var.github_repo}-"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  acl = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.static_website.arn]
    }
  }
}

resource "aws_s3_object" "error_page" {
  bucket = module.s3_bucket.s3_bucket_id
  key    = "error.html"
  source = "${path.module}/files/error.html"
  etag   = filemd5("${path.module}/files/error.html")
}

resource "aws_s3_object" "index_page" {
  bucket = module.s3_bucket.s3_bucket_id
  key    = "index.html"
  source = "${path.module}/files/index.html"
  etag   = filemd5("${path.module}/files/index.html")
}

resource "aws_cloudfront_origin_access_control" "static_website" {
  name                              = "static_website"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "static_website" {
  origin {
    domain_name              = module.s3_bucket.s3_bucket_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.static_website.id
    origin_id                = "S3Origin"
  }
  aliases = [local.fqdn]

  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  wait_for_deployment = false

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3Origin"

    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = aws_cloudfront_cache_policy.static_website.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.static_website.id
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.certificate_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [
    aws_acm_certificate.static_website
  ]
}

resource "aws_cloudfront_cache_policy" "static_website" {
  name = "static-website-cache"

  min_ttl = 300

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"

    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "static_website" {
  name = "static-website-cors"

  cors_config {
    origin_override                  = true
    access_control_allow_credentials = false
    access_control_allow_headers {
      items = ["*"]
    }
    access_control_allow_methods {
      items = ["GET"]
    }
    access_control_allow_origins {
      items = ["*.fuw.ch"]
    }
  }
}

data "cloudflare_zone" "zone" {
  name = local.zone_name
}

resource "cloudflare_record" "static_website" {
  zone_id = data.cloudflare_zone.zone.id
  name    = local.fqdn
  type    = "CNAME"
  value   = aws_cloudfront_distribution.static_website.domain_name
}

resource "cloudflare_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.static_website.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  value           = each.value.record
  ttl             = 60
  type            = each.value.type
  zone_id         = data.cloudflare_zone.zone.id
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.static_website.arn
  validation_record_fqdns = [for record in cloudflare_record.certificate_validation : record.hostname]
}

resource "aws_acm_certificate" "static_website" {
  provider          = aws.us-east-1
  domain_name       = local.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
