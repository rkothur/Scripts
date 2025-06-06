terraform {
  backend "s3" {
    bucket = "sdh-smdh-dev-terraform-state"
    key    = "smdh-emr-git-test/terraform.tfstate"
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
data "aws_availability_zones" "available" {}
data "aws_ami" "proxy_ami" {
  most_recent = true
  name_regex  = "^charter_al2023_arm64_ami*"
  owners      = ["786534693165"]
}
