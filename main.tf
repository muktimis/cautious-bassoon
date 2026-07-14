terraform {
  required_version = ">= 1.5.0"


    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0"
        }
    }


# backend "s3" {
#     bucket = "terraform-state"
#     key    = "guardrail-platform/terraform.tfstate"
#     region = "ca-central-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt = true
# }
}

provider "aws" {
  region = "ca-central-1"

  default_tags {
    tags = {
      Project = "guardrail-platform"
      managed_by = "terraform"
      owner = "mukti"
    }
  }
  
}

# data "aws_caller_identity" "current" {}
data "aws_region" "current" {}