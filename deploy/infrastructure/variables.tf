variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "@{{ app_name }}"
}

variable "app_subdomain" {
  description = "The subdomain of the application. This can be empty if the application host is the root domain."
  type        = string
  default     = null
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
  default     = "dnd-it"
}

variable "zone_name" {
  description = "The domain name of the DNS zone"
  type        = string
}
