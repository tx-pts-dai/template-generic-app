output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.this.repository_url
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_bucket.s3_bucket_id
}

output "custom_domain_names" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.static_website.aliases
}

output "iam_eks_role_arn" {
  description = "IAM role ARN for EKS"
  value       = module.iam_eks_role.iam_role_arn
}
