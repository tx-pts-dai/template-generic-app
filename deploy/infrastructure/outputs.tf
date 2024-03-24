output "ecr_repository_url" {
  description = "Container repository URL"
  value       = aws_ecr_repository.this.repository_url
}

output "iam_eks_role_arn" {
  description = "IAM role ARN to allow the Pod to have the required AWS permissions"
  value       = module.iam_eks_role.iam_role_arn
}

output "k8s_namespace" {
  description = "Kubernetes namespace where the IRSA account can be run"
  value       = local.namespace
}
