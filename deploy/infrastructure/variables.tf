variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "<GITHUB_REPO>"
}

variable "terraform_remote_state_key" {
  description = "Path to the Terraform state file of the upstream infrastructure. Needed until we have a standard path across all AWS accounts."
  type        = string
  default     = "infrastructure/terraform.tfstate"
}
