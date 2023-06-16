/**
 * Application LoadBalancer
 */
resource "aws_alb" "front" {
  name     = "${var.project}-front-${var.environment}-alb"
  internal = false

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = local.subnet_ids
  enable_deletion_protection = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_alb_target_group" "default_target_group" {
  name     = "${var.project}-default-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }

  depends_on = [
    aws_alb.front
  ]
}

# HTTP -> HTTPS redirect w/ 301
resource "aws_lb_listener" "front_80" {
  load_balancer_arn = aws_alb.front.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  depends_on = [
    aws_alb.front
  ]
}

resource "aws_alb_listener" "front_443" {
  load_balancer_arn = aws_alb.front.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = local.route53_zone_cert_arn

  default_action {
    target_group_arn = aws_alb_target_group.default_target_group.arn
    type             = "forward"
  }

  depends_on = [
    aws_alb.front
  ]
}
