terraform {
  backend "s3" {
    bucket         = "dev-remote-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
  required_providers {
    aws = {
      version = "~>5.0"
      source  = "hashicorp/aws"
    }
  }

}
