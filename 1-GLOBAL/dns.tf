/**
 * Root zone for route53
 */
# This defines the Zone for prod, stage defines its own zone.
resource "aws_route53_zone" "primary" {
  name       = var.route53_zone
  comment    = "Zone for ${var.project}"

  tags = {
    name = var.project
  }
}
