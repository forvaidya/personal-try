# Quick Start Guide: Creating trial-foobar Repository

This guide shows how to use the GitHub infrastructure Terraform configuration to create the private repository "trial-foobar".

## Prerequisites

1. **GitHub Personal Access Token**: Create a token with `repo` permissions
2. **Terraform**: Installed and available in PATH

## Steps

### 1. Navigate to the GitHub Infrastructure Directory
```bash
cd iaac-v2/github-infra/
```

### 2. Set Your GitHub Token
```bash
export GITHUB_TOKEN="your_github_token_here"
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. (Optional) Customize Configuration
Copy and modify the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred settings
```

### 5. Plan the Deployment
```bash
terraform plan
```

### 6. Create the Repository
```bash
terraform apply
```

### 7. View Repository Information
After successful creation, Terraform will output the repository URLs and other information.

## Expected Result

A private GitHub repository named "trial-foobar" will be created with:
- Private visibility
- MIT license
- VisualStudio gitignore template
- Issues, projects, wiki, and downloads enabled
- Topics: terraform, trial, infrastructure
- Vulnerability alerts enabled

## Cleanup

To remove the repository:
```bash
terraform destroy
```

**Note**: This will permanently delete the repository and all its content!