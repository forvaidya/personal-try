# Infrastructure as Code v2

This directory contains Terraform configurations for managing infrastructure across different platforms.

## Directory Structure

### core-infra/
Core AWS infrastructure including VPC, subnets, NAT gateways, and security groups.

### ecs-infra/
AWS ECS (Elastic Container Service) infrastructure that depends on the core infrastructure.

### github-infra/
GitHub repository management infrastructure for creating and managing GitHub repositories via Terraform.

## Getting Started

Each subdirectory contains its own README.md with specific instructions for that infrastructure component.

### Prerequisites

1. **AWS CLI** configured with appropriate credentials for AWS infrastructure
2. **Terraform** installed (version 1.13+ recommended)
3. **GitHub Personal Access Token** for GitHub infrastructure management

### Common Workflow

1. Navigate to the specific infrastructure directory
2. Review the README.md for specific requirements
3. Initialize Terraform: `terraform init`
4. Plan changes: `terraform plan`
5. Apply changes: `terraform apply`

## State Management

Each infrastructure component uses S3 backend for state management (when AWS credentials are available). State files are stored in the S3 bucket `mahesh-tf-state-521170656618` under the respective paths.

## Dependencies

- **ecs-infra** depends on **core-infra** (uses remote state)
- **github-infra** is independent and can be managed separately