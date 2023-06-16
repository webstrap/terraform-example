locals {
  use_docdb = var.service_docdb ? 1 : 0
}

resource "aws_docdb_cluster" "docdb" {
  count = local.use_docdb

  availability_zones      = var.availability_zones
  cluster_identifier      = "${var.project}-${var.environment}-cluster"
  engine                  = var.service_docdb_engine
  master_username         = var.service_docdb_master_username
  master_password         = var.service_docdb_master_password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  engine_version          = var.service_docdb_engine_version
  db_subnet_group_name    = aws_docdb_subnet_group.docdb[0].id

  vpc_security_group_ids = concat([
    aws_security_group.docdb[0].id,
  ])
}

resource "aws_docdb_cluster_instance" "docdb" {
  count = local.use_docdb

  apply_immediately  = true
  identifier         = "${var.project}-${var.environment}-${var.service_name}"
  cluster_identifier = aws_docdb_cluster.docdb[count.index].cluster_identifier
  instance_class     = var.service_docdb_instance_class
}

resource "aws_security_group" "docdb" {
  count = local.use_docdb

  name = "${var.project}-${var.environment}-${var.service_name}-docdb-sg"
  description = "${var.project}-${var.environment}-${var.service_name}-docdb-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-${var.environment}-${var.service_name}-docdb-sg"
  }

  ingress {
    from_port = 27017
    to_port = 27017
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

resource "aws_docdb_subnet_group" "docdb" {
  count = local.use_docdb
  name       = "${var.project}-${var.environment}-${var.service_name}-docdb-subnet-group"

  tags = {
    Name = "${var.project}-${var.environment}-${var.service_name}-docdb-subnet-group"
  }

  subnet_ids = var.subnet_ids
}
