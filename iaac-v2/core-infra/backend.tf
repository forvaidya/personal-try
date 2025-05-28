terraform {
  backend "s3" {
    bucket         = "mahesh-tf-state-521170656618"
    key            = "terraform/iaac-v2/core-infra/my-state.tfstate"
    region         = "ap-south-1" # AWS Mumbai region
    dynamodb_table = "mahes-tf-state-lock"
    encrypt        = true
  }
}