variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "image_tag" {
  description = "The tag of the image to deploy"
  type        = string
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "@{{ github_repo }}"
}

variable "github_org" {
  description = "Git organization name"
  type        = string
  default     = "dnd-it"
}

variable "deployment_annotations" {
  description = "Annotations to add to the Kubernetes Deployment"
  type        = map(string)
  default     = {}
}

variable "tf_state_bucket" {
  description = "The name of the S3 bucket where Terraform states are stored"
  type        = string
}

variable "infra_tf_state_key" {
  description = "The key of the Terraform state file for the infrastructure"
  type        = string
}