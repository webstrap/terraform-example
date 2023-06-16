resource "aws_route53_zone" "stage" {
  name = var.route53_zone
}

/**
 * NS Records in the GLOBAL zone to have a dedicated zone for this environment
 */
resource "aws_route53_record" "ns" {
  zone_id = data.terraform_remote_state.global_state.outputs.root_zone_id
  name = var.route53_zone
  type = "NS"
  ttl = "30"
  records = [
    aws_route53_zone.stage.name_servers[0],
    aws_route53_zone.stage.name_servers[1],
    aws_route53_zone.stage.name_servers[2],
    aws_route53_zone.stage.name_servers[3]
  ]
}

/**
 * Route53 record (apex)
 */
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.stage.id
  name = var.route53_zone
  type = "A"

  alias {
    name = aws_alb.front.dns_name
    zone_id = aws_alb.front.zone_id
    evaluate_target_health = true
  }
}
