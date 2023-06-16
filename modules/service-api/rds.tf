locals {
  use_rds = var.service_rds ? 1 : 0
}

resource "aws_db_parameter_group" "mysql" {
  count = local.use_rds

  name = "${var.project}-${var.environment}-${var.service_name}-parameter-group"
  description = "${var.project}-${var.environment}--${var.service_name}-parameter-group"

  family = var.service_rds_parameter_group_family

  parameter {
    name = "character_set_server"
    value = "utf8"
  }

  parameter {
    name = "character_set_client"
    value = "utf8"
  }

  parameter {
    name  = "lower_case_table_names"
    value = "1"
    apply_method = "pending-reboot"
  }
}

resource "aws_db_subnet_group" "mysql" {
  count = local.use_rds

  name = "${var.project}-${var.environment}-${var.service_name}-mysql-subnet-group"
  description = "${var.project}-${var.environment}-${var.service_name}"

  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project}-${var.environment}-${var.service_name}-mysql-subnet-group"
  }
}

resource "aws_security_group" "mysql" {
  count = local.use_rds

  name = "${var.project}-${var.environment}-${var.service_name}-mysql-sg"
  description = "${var.project}-${var.environment}-${var.service_name}-mysql-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-${var.environment}-${var.service_name}-mysql-sg"
  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"

    security_groups = concat([
      // extend as needed
    ], var.additional_security_group_ids)
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "time_static" "epoch" {}

locals {
  final_snapshot_identifier_stripped = replace("${var.environment}x${var.service_name}xfinalx${time_static.epoch.unix}", "/[^a-zA-Z0-9]/", "")
}

resource "aws_db_instance" "mysql" {
  count = local.use_rds

  db_name = var.service_rds_node_database_name
  identifier = "${var.project}-${var.environment}-${var.service_name}-rds-instance"

  port = 3306
  allocated_storage = var.service_rds_node_storage_size

  engine = "mysql"
  engine_version = var.service_rds_mysql_version

  instance_class = var.service_rds_node_instance_type
  storage_type = var.service_rds_node_storage_type

  username = var.service_name
  password = var.service_rds_password

  publicly_accessible = false

  vpc_security_group_ids = concat([
    aws_security_group.mysql[count.index].id,
  ], var.additional_security_group_ids)

  db_subnet_group_name = aws_db_subnet_group.mysql[count.index].id
  parameter_group_name = aws_db_parameter_group.mysql[count.index].name

  multi_az = false
  backup_retention_period = 14
  backup_window = "02:00-03:00"
  maintenance_window = "sun:03:30-sun:04:30"
  final_snapshot_identifier = local.final_snapshot_identifier_stripped

  tags = {
    Name = "${var.project}-${var.environment}-${var.service_name}-rds-instance"
    Group = var.project
  }

  apply_immediately = true

  lifecycle {
    ignore_changes = [ engine_version ]
    prevent_destroy = false
  }
}
