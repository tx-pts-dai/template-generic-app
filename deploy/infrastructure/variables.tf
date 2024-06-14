variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ application_name }}"
}

variable "app_subdomain" {
  description = "The subdomain of the application. This can be empty if the application host is the root domain."
  type        = string
  default     = ""
}

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
  default     = "dnd-it" # TODO: template var?
}


variable "dns_zone_domain" {
  description = "The domain name of the DNS zone"
  type        = string
}

variable "terraform_remote_state_key" {
  description = "Path to the Terraform state file of the upstream infrastructure. Needed until we have a standard path across all AWS accounts."
  type        = string
  default     = "infrastructure/terraform.tfstate" # TODO: move into <env>.tfvars ?
}

variable "team_name" {
  description = "The name of the team that owns the application."
  type        = string
}