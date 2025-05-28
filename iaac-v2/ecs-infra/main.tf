variable "project_name" {
  description = "Project name"
  type        = string
  default     = "boston"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket         = "mahesh-tf-state-521170656618"
    key            = "terraform/iaac-v2/core-infra/my-state.tfstate"
    region = var.region
  }
}



output "vpc_id" {
  description = "full from core-infra remote state"
  value       = data.terraform_remote_state.core.outputs.vpc_id
}


