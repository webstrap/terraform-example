terraform {
  backend "s3" {
    bucket = "example-terraform-state"
    region = "eu-central-1"
    key    = "stage.terraform.tfstate"
    profile = "example-profile"
    dynamodb_table = "example-terraform-lock"
  }
}

# Super state config
data "terraform_remote_state" "global_state" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    region = var.region
    key    = var.tf_state_key_super
    profile = "example-profile"
    dynamodb_table = "example-terraform-lock"
  }
}

# aws provider setting
provider "aws" {
  region  = var.region
  profile = var.project
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      Terraform   = true
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
  profile = var.project
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      Terraform   = true
    }
  }
}

locals {
  root_zone_id  = aws_route53_zone.stage.id
  instance_role = data.terraform_remote_state.global_state.outputs.instance_role
  vpc_id        = aws_vpc.main.id
}

data "aws_availability_zones" "available" {}

data "aws_elb_service_account" "main" {}

# AMI selector for ECS-Optimized AMI
/*
Execute to see the values that are returned by the full object:
    aws ec2 describe-images --region eu-central-1 \
    --owners 075585003325 --filters "Name=architecture,Values=x86_64" \
    "Name=virtualization-type,Values=hvm" "Name=name,Values=Flatcar-stable-*" \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId'
*/
data "aws_ami" "flatcar_ami" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Flatcar-stable-*"]
  }

  owners     = ["075585003325"]
}

data "aws_docdb_engine_version" "latest" {
  version = "3.6.0"
}
