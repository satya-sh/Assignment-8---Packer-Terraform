terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.55.0, < 6.0.0"
    }
  }
  
  required_version = ">= 1.3.0, < 2.0.0"
}