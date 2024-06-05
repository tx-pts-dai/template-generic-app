variable "environment" {
  description = "value of the environment tag"
  type        = string
}

variable "github_repo" {
  description = "Git repository name"
  type        = string
  default     = "j2{{ github_repo }}"
}

variable "hostname" {
  description = "DNS name where to host the application"
  type        = string
}

variable "dns_zone_domain" {
  description = "The domain name of the DNS zone"
  type        = string
}

variable "terraform_remote_state_key" {
  description = "Path to the Terraform state file of the upstream infrastructure. Needed until we have a standard path across all AWS accounts."
  type        = string
  default     = "infrastructure/terraform.tfstate"
}
