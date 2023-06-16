terraform {
  backend "s3" {
    bucket = "example-terraform-state"
    region = "eu-central-1"
    key    = "global.terraform.tfstate"
    // This are AWS-CLI profiles, check the root README setup for further instructions
    profile = "example-profile"
    dynamodb_table = "example-terraform-lock"
  }
}


# aws provider setting
provider "aws" {
  region = var.region
  profile = local.project
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      Terraform   = true
    }
  }
}

# This aliased provider is required to
# provision certificates in the AWS root
# region for use with Cloudfront
# distributions.
#
# !! NOTE !!
#
# if region is us-east-1, change the boolean
# in the local below to false!
provider "aws" {
  region = "us-east-1"
  profile = local.project
  allowed_account_ids = [var.aws_account_id]
  alias = "ue1"
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      Terraform   = true
    }
  }
}
