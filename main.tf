terraform {
<<<<<<< HEAD
  required_version = ">= 1.3.0"

=======
  required_version = ">= 1.0"
  
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
<<<<<<< HEAD
=======
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
  }
}

provider "aws" {
  region = var.aws_region
<<<<<<< HEAD
}
=======
  
  default_tags {
    tags = {
      Project     = "CloudStream"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Team        = "DevOps"
    }
  }
}

# 현재 AWS 계정 ID 가져오기
data "aws_caller_identity" "current" {}

# 현재 리전 가져오기
data "aws_region" "current" {}
>>>>>>> 098bf4fb2a3fcc45cc2fbb8e1578dd367ddf7322
