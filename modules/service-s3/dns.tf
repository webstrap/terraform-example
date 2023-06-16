resource "aws_route53_record" "service" {
  zone_id = var.route53_root_zone_id
  name = local.route53_fqdn
  type = "A"

  alias {
    name = aws_cloudfront_distribution.cdn.domain_name
    zone_id = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = true
  }
}
