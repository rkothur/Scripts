terraform {
  required_version = ">= 1.4"

  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "0.8.3"
    }
  }
}

provider "aws" {
  region = local.region
} 

terraform {
  backend "s3" {
    bucket = "ramtest1-terraform-state"
    key    = "sdl-dev-msk-topic-create/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}