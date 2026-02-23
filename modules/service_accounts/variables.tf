variable "client_name" {
  description = "Client identifier used as a prefix for service account IDs (e.g. acmecorp)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,28}[a-z0-9]$", var.client_name))
    error_message = "client_name must be 2-30 characters, start with a lowercase letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "env" {
  description = "Deployment environment (dev, stg, or prd)"
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prd"], var.env)
    error_message = "env must be one of: dev, stg, prd."
  }
}

variable "project_id" {
  description = "GCP project ID where service accounts are created"
  type        = string
}
