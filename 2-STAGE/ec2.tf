resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.environment}-ecs-main-cluster"
}

resource "aws_spot_fleet_request" "ecs-main-spot-fleet" {
  iam_fleet_role = data.terraform_remote_state.global_state.outputs.instance_role
  target_capacity = 3

  allocation_strategy = "lowestPrice"

  instance_interruption_behaviour = "terminate"
  terminate_instances_with_expiration = true
  replace_unhealthy_instances = true

  launch_template_config {

    launch_template_specification {
      id = aws_launch_template.ecs-main-spot-fleet-tl.id
      version = aws_launch_template.ecs-main-spot-fleet-tl.latest_version
    }

    // M5A, C5A, R5A INSTANCES
    overrides {
      instance_type = "m5a.xlarge"
      subnet_id = aws_subnet.secondary.id
    }

    # the array notation with [0] is here because the definition contains a count
    # which makes it an option element in a list, depending on what is passed.
    overrides {
      instance_type = "m5a.xlarge"
      subnet_id = aws_subnet.tertiary[0].id
    }

    overrides {
      instance_type = "m5a.2xlarge"
      # it is required to add a subnet id to all overrides, otherwise an empty string subnet will be added
      # which results in an error that not all subnets are in the same VPC
      # (in AWS, terraform creates the request without complaining)
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "c5a.xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "c5a.2xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "r5a.xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "r5a.2xlarge"
      subnet_id = aws_subnet.primary.id
    }

    // M5N, C5N, R5N INSTANCES

    overrides {
      instance_type = "m5n.xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "m5n.2xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "c5n.xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "c5n.2xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "r5n.xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "r5n.2xlarge"
      subnet_id = aws_subnet.primary.id
    }

    // M5, C5, R5 INSTANCES

    overrides {
      instance_type = "m5.xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "m5.2xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "c5.xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "c5.2xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "r5.xlarge"
      subnet_id = aws_subnet.primary.id
    }

    overrides {
      instance_type = "r5.2xlarge"
      subnet_id = aws_subnet.primary.id
    }
  }

  tags = {
    Name = "${var.project}-${var.environment}-ecs-main-sfr"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "ecs-main-spot-fleet-tl" {
  name = "${var.project}-${var.environment}-ecs-main-spot-fleet-tl"
  tags = {
    Name = "${var.project}-${var.environment}-ecs-main-spot-fleet-tl"
  }

  image_id = data.aws_ami.flatcar_ami.image_id
  instance_type = "m5a.xlarge"
  key_name = var.ec2-ssh-key-name

  iam_instance_profile {
    arn = data.terraform_remote_state.global_state.outputs.instance_profile_role_arn
  }

  vpc_security_group_ids = [
    aws_security_group.web.id,
    module.wireguard.vpn_sg_admin_id,
  ]

  user_data = base64encode(data.template_file.ecs_main_spot_fleet_user_data.rendered)

  block_device_mappings {
    device_name = "sdf"

    ebs {
      volume_size = "100"
      volume_type = "gp2"
      delete_on_termination = true
    }
  }



  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-${var.environment}-ecs-main-spot-node"
    }
  }


  lifecycle {
    ignore_changes = [
      image_id
    ]
    create_before_destroy = true
  }
}

data "template_file" "ecs_main_spot_fleet_user_data" {
  template = file("files/userdata.sh")

  vars = {
    project = var.project
    region  = var.region
    environment = var.environment
    ecs_cluster = aws_ecs_cluster.main.name
  }
}
