terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  # The token should be provided via GITHUB_TOKEN environment variable
  # or through other secure means in a real environment
  token = var.github_token
}

# Create the trial-foobar private repository
resource "github_repository" "trial_foobar" {
  name        = var.repository_name
  description = var.repository_description

  visibility = var.repository_visibility

  # Additional repository settings
  has_issues    = true
  has_projects  = true
  has_wiki      = true
  has_downloads = true

  # Enable vulnerability alerts
  vulnerability_alerts = true

  # Default branch settings
  auto_init          = true
  gitignore_template = "VisualStudio"
  license_template   = "mit"

  topics = var.repository_topics
}