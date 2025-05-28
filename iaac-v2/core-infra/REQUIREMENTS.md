project name: boston (# Variable)
Environmemnt - dev (# variable)
region: ap-south-1 (#variable)

while deriving ressource names please make 
Network:
   A vpc with 3 private subnet and 3 public subnet
   For priavte subnet make NAT.
   Select VPC CIDR sufficient to give 60 ips each subnet
   Setup necessary logging in cloud watch

Task: generate Terraform code.
I will provide state backend bucket and the object
make a seperate backend.tf
keep provider seperate
make 2 provider alisases default ap-south-1 and another for us-east-1

terraform {
  backend "s3" {
    # Fill in these values with your backend configuration:
    # bucket         = "your-terraform-state-bucket"
    # key            = "boston-dev/terraform.tfstate"
    # region         = "ap-south-1"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
  }
}

