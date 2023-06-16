resource "aws_security_group" "sg_wireguard_external" {
  name = "${var.project}-${var.environment}-wireguard-external"
  description = "Terraform Managed. Allow Wireguard client traffic from internet."
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-${var.environment}-wireguard-external"
  }

  ingress {
    from_port = var.wg_server_port
    to_port = var.wg_server_port
    protocol = "udp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sg_wireguard_admin" {
  name = "${var.project}-${var.environment}-wireguard-admin"
  description = "Terraform Managed. Allow admin traffic to internal resources from VPN"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-${var.environment}-wireguard-admin"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [
      aws_security_group.sg_wireguard_external.id]
  }

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    security_groups = [
      aws_security_group.sg_wireguard_external.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
