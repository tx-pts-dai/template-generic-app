variable "image_tag" {
  description = "The tag of the image to deploy"
  type        = string
  default     = "latest"
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
}

variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "app_config" {
  description = "Application configuration"
  type        = any
  default     = {}
}
