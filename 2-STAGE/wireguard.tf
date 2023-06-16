locals {
  # This variable is used below for the WireGuard network
  # it connects then the VPC and the developers on that network
  wireguard-server-net = "192.168.2.1/24"
  wireguard-server-port = "5000"
  wg_clients = [
    # User1
    { "192.168.2.2/32" = "xxxxxxxxxxxxxxxxxxxxxxxxx" },
    # user2
    { "192.168.2.3/32" = "xxxxxxxxxxxxxxxxxxxxxxxxx" },
  ]
}

resource "aws_eip" "wireguard-bastion" {
  vpc = true

  tags = {
    Name = "${var.environment}-wireguard-bastion"
  }
}

resource "aws_security_group" "wireguard-bastion" {
  name   = "${var.environment}-wireguard-bastion-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-wireguard-bastion"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "wireguard" {
  source        = "../modules/wireguard"

  ssh_key_id    = var.ec2-ssh-key-name
  vpc_id        = aws_vpc.main.id
  subnet_ids    = local.subnet_ids
  eip_id        = aws_eip.wireguard-bastion.id

  instance_type = "t3a.micro"

  additional_security_group_ids = [
    aws_security_group.wireguard-bastion.id
  ]

  wg_server_net = local.wireguard-server-net
  wg_server_port = local.wireguard-server-port

  # generate private / public key pair
  wg_server_private_key = "xxxxxxxxxxxxxxxxxxxxxxxx"

  wg_client_public_keys = local.wg_clients

  region = var.region

  project = var.project
  environment = var.environment
}
