/* Terraform Version and Providers */

/*
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
  required_version = ">= 1.4"

  required_providers {
    mongodb = {
      source = "registry.terraform.io/Kaginari/mongodb"
      version = "9.9.9"
    }
  }
}
*/
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.34"
    }
    mongodb = {
      source = "registry.terraform.io/Kaginari/mongodb"
      
    }
  }
}

terraform {
  backend "s3" {
    bucket = "sdh-smdh-dev-terraform-state"
    key    = "ramtest-docdb-ddl-test/terraform.tfstate"
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