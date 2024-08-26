variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ app_name }}"
}

{%- if app_url_type == "subdomain" %}
variable "app_subdomain" {
  description = "The subdomain of the application. This can be empty if the application host is the root domain."
  type        = string
  default     = "@{{ app_subdomain }}"
}
{%- endif %}

variable "environment" {
  description = "value of the environment tag"
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

variable "zone_name" {
  description = "The domain name of the DNS zone"
  type        = string
}

variable "tf_state_bucket" {
  description = "The name of the S3 bucket where Terraform states are stored"
  type        = string
}

variable "infra_tf_state_key" {
  description = "The key of the Terraform state file for the infrastructure"
  type        = string
}