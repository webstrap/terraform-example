resource "aws_route53_record" "service" {
  zone_id = var.route53_root_zone_id
  name = local.route53_fqdn
  type = "A"

  alias {
    name = var.alb_front_dns_name
    zone_id = var.alb_front_zone_id
    evaluate_target_health = true
  }
}
