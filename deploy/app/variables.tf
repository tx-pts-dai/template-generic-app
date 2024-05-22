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

variable "app" {
  description = "Application settings"
  type = object({
    name      = optional(string)
    namespace = optional(string)
    url       = optional(string)
  })
}

variable "image_tag" {
  description = "The tag of the image to deploy"
  type        = string
  default     = "latest"
}

variable "platform_remote_state" {
  description = "Platform remote state configuration"
  type = object({
    bucket = string
    key    = string
    region = string
  })
}

variable "infra_remote_state" {
  description = "Infra remote state configuration"
  type = object({
    bucket = string
    key    = string
    region = string
  })
}
