variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ application_name }}" # TODO: move into <env>.tfvars ?
}

variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "image_tag" {
  description = "The tag of the image to deploy"
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "@{{ github_repo }}"
}

variable "github_org" {
  description = "Git organization name"
  type        = string
}

variable "node_pool" {
  description = "Name of the Karpenter NodePool to use"
  type        = string
  default     = "default"
}

variable "terraform_remote_state_key" {
  description = "Path to the Terraform state file of the upstream infrastructure. Needed until we have a standard path across all AWS accounts."
  type        = string
  default     = "@{{ infra_repo }}/platform/terraform.tfstate" # TODO: move into <env>.tfvars ?
}

variable "deployment_annotations" {
  description = "Annotations to add to the Kubernetes Deployment"
  type        = map(string)
  default     = {}
}