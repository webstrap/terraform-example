variable "project" {
  description = "Cluster name this service is part of."
}

variable "region" {
  default = "eu-central-1"
}

variable "environment" {
  description = "Used as suffix for resource names."
}

variable "repository" {
  description = "GitHub repository of this project."
}

variable "service_name" {
  description = "Name of this managed service."
}

variable "s3_bucket_name" {
  description = "Name of the s3 bucket to be used by this CF distribution."
}

variable "s3_bucket_prefix" {
  description = "Prefix to be used by the CF distribution when routing requests into the S3 bucket."
}

variable "cf_acm_cert" {
  description = "ACM certificate to be used by the CF distribution. Must have been deployed in us-east-1."
}

variable "cf_min_ttl" {
  description = "Minimum TTL of objects delivered by the CF distribution."
  default = 0
}

variable "cf_default_ttl" {
  description = "Default TTL of objects delivered by the CF distribution."
  default = 3600
}

variable "cf_max_ttl" {
  description = "Maximum TTL of objects delivered by the CF distribution."
  default = 86400
}

variable "route53_root_zone_id" {
  description = "Route53 root zone id (aka id of domain)."
}

variable "route53_zone" {
  description = "Route53 root zone name (aka name of domain)."
}

locals {
  route53_fqdn = "${var.service_name}.${var.route53_zone}"

  create_github_resources = var.repository != null
}
