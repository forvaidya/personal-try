# GitHub Infrastructure

This Terraform configuration manages GitHub repositories and related resources.

## Prerequisites

1. **GitHub Personal Access Token**: You need a GitHub personal access token with appropriate permissions:
   - `repo` (for private repositories)
   - `public_repo` (for public repositories)
   - `admin:org` (if creating repositories in an organization)

2. **Set Environment Variable**: 
   ```bash
   export GITHUB_TOKEN="your_github_token_here"
   ```

## Usage

### Initialize Terraform
```bash
terraform init
```

### Plan Changes
```bash
terraform plan
```

### Apply Changes
```bash
terraform apply
```

### Destroy Resources
```bash
terraform destroy
```

## Configuration

The configuration creates a private GitHub repository named "trial-foobar" with the following features:
- Private visibility
- Issues, projects, wiki, and downloads enabled
- Vulnerability alerts enabled
- MIT license
- VisualStudio gitignore template
- Topics: terraform, trial, infrastructure

## Variables

- `repository_name`: Name of the repository (default: "trial-foobar")
- `repository_description`: Description of the repository
- `repository_visibility`: Repository visibility - "private" or "public" (default: "private")
- `repository_topics`: List of topics for the repository
- `github_token`: GitHub personal access token (sensitive)

## Outputs

- `repository_name`: Name of the created repository
- `repository_url`: HTML URL of the repository
- `repository_clone_url`: HTTPS clone URL
- `repository_ssh_clone_url`: SSH clone URL
- `repository_git_clone_url`: Git clone URL
- `repository_full_name`: Full name (owner/repo)

## Security Considerations

- Store the GitHub token securely using environment variables or a secret management system
- Use appropriate IAM permissions for the S3 backend
- Consider using GitHub Apps instead of personal access tokens for production use