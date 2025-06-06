/* Terraform Version and Providers */

terraform {
  required_version = ">= 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "sdh-smdh-dev-terraform-state"
    key    = "smdh-mls-mwaa-test/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}


data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

/* Charter OS Image */

data "aws_ami" "proxy_ami" {
  most_recent = true
  name_regex  = "^charter_amzn_2_ami*"
  owners      = ["786534693165"]
}