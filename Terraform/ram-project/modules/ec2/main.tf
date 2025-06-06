
terraform {
  backend "s3" {
    bucket = "sdh-smdh-dev-terraform-state"
    key    = "smdh-dev-ec2-create/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      # Mandatory Tags
      app_id     = "APP2560"
      cost_code  = "3047100821"
      app_ref_id = "mtDDh"
    }
  }
}


data "aws_caller_identity" "current" {}