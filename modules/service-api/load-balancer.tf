resource "aws_alb_target_group" "service_tg" {
  name = "${local.full_service_name}-tg"
  port = var.service_port
  protocol = "HTTP"
  vpc_id = var.vpc_id

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path = var.service_health_check_path

    interval = var.service_health_interval
    timeout = var.service_health_timeout

    healthy_threshold = var.service_healthy_threshold
    unhealthy_threshold = var.service_unhealthy_threshold
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = var.ecs_alb_front_arn

  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.service_tg.arn
  }

  condition {
    host_header {
      values = [
        local.route53_fqdn
      ]
    }
  }
}
