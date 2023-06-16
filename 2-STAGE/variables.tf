variable "aws_account_id" {
  description = "The project is limited to this AWS account"
  default = "111111111111"
}

provider "github" {
  owner = "example-github-org"
  token = "ghp_1111111111111111111111111"
}

variable "project" {
  default = "example-project"
}

variable "region" {
  default = "eu-central-1"
}

variable "environment" {
  default = "stage"
}

variable "tf_state_bucket" {
  default = "example-terraform-state"
}

variable "tf_state_key_super" {
  default = "global.terraform.tfstate"
}

variable "ec2-ssh-key-name" {
  default = "example-terraform-ec2-key"
}

variable "vpc_main_cidr" {
  description = "CIDR for VPC"
  default     = "10.31.0.0/16"
}

variable "vpc_primary_subnet_cidr" {
  description = "CIDR for primary subnet"
  default     = "10.31.0.0/20"
}

variable "vpc_secondary_subnet_cidr" {
    description = "CIDR for secondary subnet"
    default     = "10.31.16.0/20"
}

variable "vpc_tertiary_subnet_cidr" {
  description = "CIDR for tertiary subnet"
  default     = "10.31.32.0/20"
}

locals {
  lambda_artifacts_bucket = "${var.project}-${var.environment}-lambda-artifacts"
}

variable "route53_zone" {
  default = "stage.example.com"
}

variable "route53_zone_internal" {
  default = "stage.internal.example.com"
}

variable "rds_password" {
  default = "XXXXXXXXXXXX"
}

locals {
  route53_zone_cert_arn     = data.terraform_remote_state.global_state.outputs.route53_zone_cert_arn
  ue1_route53_zone_cert_arn = data.terraform_remote_state.global_state.outputs.ue1_route53_zone_cert_arn
}

locals {
  subnet_ids = (
  local.count_tertiary == 0
  ? [
    aws_subnet.primary.id,
    aws_subnet.secondary.id,
  ]
  : [
    aws_subnet.primary.id,
    aws_subnet.secondary.id,
    aws_subnet.tertiary[0].id,
  ]
  )
}

# DocumentDb configuration
variable "docdb_engine" {
  default = "docdb"
}

variable "docdb_master_username" {
  default = "example-admin"
}

variable "docdb_master_password" {
  default = "XXXXXXXXXXX"
}

variable "docdb_instance_class" {
  default = "db.t3.medium"
}
