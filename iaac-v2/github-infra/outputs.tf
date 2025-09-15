output "repository_name" {
  description = "Name of the created repository"
  value       = github_repository.trial_foobar.name
}

output "repository_url" {
  description = "URL of the created repository"
  value       = github_repository.trial_foobar.html_url
}

output "repository_http_clone_url" {
  description = "HTTP clone URL of the created repository"
  value       = github_repository.trial_foobar.http_clone_url
}

output "repository_ssh_clone_url" {
  description = "SSH clone URL of the created repository"
  value       = github_repository.trial_foobar.ssh_clone_url
}

output "repository_git_clone_url" {
  description = "Git clone URL of the created repository"
  value       = github_repository.trial_foobar.git_clone_url
}

output "repository_full_name" {
  description = "Full name of the repository (owner/repo)"
  value       = github_repository.trial_foobar.full_name
}