terraform {
  backend "s3" {
    bucket = "sdh-smdh-dev-terraform-state"
    key    = "iam-emr7/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}

terraform {
  required_version = ">= 1.4"

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
        app           = "smdh-dev" 
        app_id        = "APP2560" 
        cost_code     = "3047100821" 
        team          = "dp-sdh-pe" 
        data_priv     = "Internal"
        group         = "sdh" 
        vp            = "Nate Vogel" 
        org           = "data-platforms" 
        ops_owner     = "Mani Kalyan" 
        sec_owner     = "Mani Kalyan" 
        dev_owner     = "Mani kalyan" 
        app_ref_id    = "mtDDh"
        solution      = "smdh"
    }
  }
}
data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}
data "aws_ami" "proxy_ami" {
  most_recent = true
  name_regex  = "^charter_al2023_x86_64_ami*"
  owners      = ["786534693165"]
}