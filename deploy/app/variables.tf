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

variable "namespace" {
  description = "Kubernetes namespace to deploy the application to"
  type        = string
  default     = ""
}

variable "hostname" {
  description = "DNS name where to host the application"
  type        = string
}

variable "image_tag" {
  description = "The tag of the image to deploy"
  type        = string
  default     = "latest"
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "<GITHUB_REPO>"
}

variable "provisioner_group" {
  description = "Name of the provisioner group to use"
  type        = string
  default     = "<PROVISIONER_GROUP>"
}

variable "terraform_remote_state_key" {
  description = "Path to the Terraform state file of the upstream infrastructure. Needed until we have a standard path across all AWS accounts."
  type        = string
}

variable "deployment_annotations" {
  description = "Annotations to add to the Kubernetes Deployment"
  type        = map(string)
  default     = {}
}
