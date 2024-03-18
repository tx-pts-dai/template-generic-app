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

variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "terraform_remote_state_key" {
  description = "Path to the Terraform state file of the upstream infrastructure"
  type        = string
  default     = "infrastructure/terraform.tfstate"
}
