locals {
  acm_san = [
    "*.${var.route53_zone}",
    "*.stage.${var.route53_zone}",
    "*.prod.${var.route53_zone}",
  ]

  domains = concat([
    var.route53_zone,
  ], local.acm_san)

  domain_count = length(local.domains)
}

resource "aws_acm_certificate" "default" {
  domain_name = var.route53_zone

  subject_alternative_names = local.acm_san

  tags = {
    Name = var.route53_zone
  }

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  flattened_domains = flatten(aws_acm_certificate.default.*.domain_validation_options)
}

resource "aws_route53_record" "acm_validation_record" {
  count = local.domain_count

  zone_id = aws_route53_zone.primary.zone_id

  ttl = 30

  name = lookup(local.flattened_domains[count.index], "resource_record_name")
  type = lookup(local.flattened_domains[count.index], "resource_record_type")

  allow_overwrite = true

  records = [
    lookup(local.flattened_domains[count.index], "resource_record_value")
  ]

  depends_on = [
    aws_acm_certificate.default
  ]
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.default.arn

  validation_record_fqdns = aws_route53_record.acm_validation_record.*.fqdn

  depends_on = [
    aws_acm_certificate.default,
    aws_route53_record.acm_validation_record,
  ]
}

# ue1 = us-east-1
# When you want to use AWS certificates for CloudFront they have to be issued
# from the US, so even when the whole infra is in europe, you still need US certificates.
# That means for EU setups we need for the ALB an EU certificate but for cloudfront the US certificate.
# So you need to create the certificates in both regions at the same time.
resource "aws_acm_certificate" "ue1" {
  # count is a fixed variable, when the value of count is zero, the resource will not be build
  # when it's above 1, it creates multiple resources.
  count = local.ue1_acm_register ? 1 : 0

  provider = aws.ue1

  domain_name = var.route53_zone

  subject_alternative_names = local.acm_san

  tags = {
    Name = var.route53_zone
  }

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
