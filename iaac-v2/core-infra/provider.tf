provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "boston-dev"
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "boston-dev"
      ManagedBy   = "terraform"
    }
  }
}