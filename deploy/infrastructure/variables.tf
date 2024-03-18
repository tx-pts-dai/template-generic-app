variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "<APPLICATION_NAME>"
}

variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "hostname" {
  description = "The name of the domain that is used to host the static website"
  type        = string
}
