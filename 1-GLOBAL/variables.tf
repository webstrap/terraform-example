
variable "aws_account_id" {
  description = "The project is limited to this AWS account"
  default = "111111111111"
}

# A project name
# this is as well the AWS profile which you need to configure in
# ~/.aws/config and ~/.aws/credentials
variable "project" {
  default = "example-project"
}

# AWS Region
variable "region" {
  default = "eu-central-1"
}

variable "environment" {
  default = "global"
}


locals {
  # when in the US, then the acm-root creates already a registrar
  # when in the EU, you still need for CloudFront US certificates
  ue1_acm_register = true
  project = "example-project"
}

# Route53 root zone
variable "route53_zone" {
  default = "example.com"
}

variable "primary_domain_set_ns" {
  type    = bool
  default = false
}

variable "iam_groups" {
  description = "IAM groups to be created"
  default = ["developers", "admins"]
}


locals {
  users_developers = {
    example-user1 = {
      group = aws_iam_group.group["developers"].name,
    },
    example-user2 = {
      group = aws_iam_group.group["developers"].name,
    },
  }

  users_admins = {
    example-admin = {
      group = aws_iam_group.group["admins"].name,
    },
  }
  users = merge(local.users_developers, local.users_admins)
}
