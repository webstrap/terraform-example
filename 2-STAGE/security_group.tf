/**
 * Security group for api
 */
resource "aws_security_group" "web" {
  name = "${var.project}-${var.environment}-web"
  description = "security group for ${var.project} web"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_groups = [
      module.wireguard.vpn_sg_admin_id
    ]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 32768
    to_port     = 65535
    description = "Access from ALB"

    security_groups = [
      aws_security_group.alb.id,
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

/**
 * Security group for ALB
 */
resource "aws_security_group" "alb" {
  name = "${var.project}-${var.environment}-alb"
  description = "security group for ${var.project} alb"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "mongo" {
  name = "${var.project}-${var.environment}-mongo"
  description = "security group for ${var.project} mongo"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "MongoDB Access"

    from_port = 27017
    to_port = 27017
    protocol = "tcp"

    security_groups = [
      aws_security_group.web.id,
      module.wireguard.vpn_sg_admin_id,
    ]
  }

  egress {
    from_port = 0
    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}
