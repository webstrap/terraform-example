locals {
  managed_s3_services = {
    firstfrontend = {
      repository = "firstfrontend",

      s3_bucket = aws_s3_bucket.main.bucket,
      s3_prefix = "/firstfrontend-${var.environment}",

      acm_cert = local.ue1_route53_zone_cert_arn,
    },

    secondfrontend = {
      repository = "secondfrontend",

      s3_bucket = aws_s3_bucket.main.bucket,
      s3_prefix = "/secondfrontend-${var.environment}",

      cf_min_ttl = 0,
      cf_default_ttl = 1,
      cf_max_ttl = 1,

      acm_cert = local.ue1_route53_zone_cert_arn,
    },
  }
}

module "managed_s3_buckets" {
  for_each = local.managed_s3_services

  source = "../modules/service-s3"

  service_name = each.key

  repository = each.value.repository

  s3_bucket_name = each.value.s3_bucket
  s3_bucket_prefix = each.value.s3_prefix

  cf_acm_cert = each.value.acm_cert
  cf_min_ttl = lookup(each.value, "cf_min_ttl", 0)
  cf_default_ttl = lookup(each.value, "cf_default_ttl", 3600)
  cf_max_ttl = lookup(each.value, "cf_max_ttl", 86400)

  environment = var.environment
  project = var.project

  route53_root_zone_id = local.root_zone_id
  route53_zone = var.route53_zone

  depends_on = [
    aws_s3_bucket.main,
  ]
}

output "managed_s3_buckets" {
  value = module.managed_s3_buckets
}
