variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ app_name }}"
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

variable "external_secrets" {
  description = "List of external secrets to fetch"
  type        = list(string)
  default     = []
}

variable "scaling_enabled" {
  description = "Enable scaling (HPA) of the deployment"
  type        = bool
  default     = false
}

variable "enable_target_group_binding" {
  description = "Enable binding to target group"
  type        = bool
  default     = {% if app_url_type == "subdomain" %}false{% else %}true{% endif %}
}

variable "namespace" {
  description = "Kubernetes namespace to deploy the application into"
  type        = string
  default     = null
}

variable "tf_state_bucket" {
  description = "The name of the S3 bucket where Terraform states are stored"
  type        = string
}