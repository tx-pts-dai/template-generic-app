variable "region" {
  description = "The region to deploy the platform"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "environment" {
  description = "The environment to deploy the platform"
  type        = string
}

variable "ecr_repository" {
  description = "The ECR repository configuration"
  type = object({
    name                 = string
    image_tag_mutability = optional(string, "MUTABLE")
  })
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
}

variable "app_url" {
  description = "DNS name where to host the application"
  type        = string
}

variable "dns_zone" {
  description = "The domain name of the DNS zone"
  type        = string
}

variable "platform_remote_state" {
  description = "Path to the Terraform state file of the upstream infrastructure. Needed until we have a standard path across all AWS accounts."
  type = object({
    bucket = string
    key    = string
    region = string
  })
}
