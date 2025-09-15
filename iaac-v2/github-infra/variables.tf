variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
  default     = null
}

variable "repository_name" {
  description = "Name of the GitHub repository to create"
  type        = string
  default     = "trial-foobar"
}

variable "repository_description" {
  description = "Description for the GitHub repository"
  type        = string
  default     = "Trial repository created via Terraform"
}

variable "repository_visibility" {
  description = "Visibility of the repository (public, private)"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private"], var.repository_visibility)
    error_message = "Repository visibility must be either 'public' or 'private'."
  }
}

variable "repository_topics" {
  description = "Topics for the repository"
  type        = list(string)
  default     = ["terraform", "trial", "infrastructure"]
}