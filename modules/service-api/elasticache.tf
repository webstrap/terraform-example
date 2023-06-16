locals {
  use_redis = var.service_redis ? 1 : 0
}

resource "aws_security_group" "redis" {
  count = local.use_redis

  name = "${var.project}-${var.environment}-${var.service_name}-redis"

  tags = {
    Name = "${var.project}-${var.environment}-${var.service_name}-redis"
  }

  description = "security group for ${var.project} redis"
  vpc_id = var.vpc_id

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = [
      var.vpc_cidr
    ]

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

resource "aws_elasticache_parameter_group" "redis" {
  count = local.use_redis

  name = "${var.project}-${var.environment}-${var.service_name}-cache-params"
  family = var.service_redis_parameter_group_family

  parameter {
    name = "activerehashing"
    value = "yes"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  count = local.use_redis

  name        = "${var.project}-${var.environment}-${var.service_name}-elasticache-subnet-group"

  tags = {
    Name = "${var.project}-${var.environment}-${var.service_name}-elasticache-subnet-group"
  }

  subnet_ids  = var.subnet_ids
}

resource "aws_elasticache_cluster" "redis" {
  count = local.use_redis

  cluster_id           = "${var.project}-${var.environment}-${var.service_name}-redis"
  engine               = "redis"
  engine_version       = var.service_redis_version
  node_type            = var.service_redis_node_instance_type

  port                 = 6379
  num_cache_nodes      = var.service_redis_node_count

  parameter_group_name = aws_elasticache_parameter_group.redis[count.index].name
  subnet_group_name    = aws_elasticache_subnet_group.redis[count.index].name

  security_group_ids   = concat([
    // extend as needed
    aws_security_group.redis[count.index].id,
  ], var.additional_security_group_ids)

  snapshot_retention_limit    = 14
  snapshot_window             = "02:00-03:00"
  maintenance_window          = "sun:03:00-sun:04:00"

  lifecycle {
    ignore_changes = [ engine_version ]
    prevent_destroy = false
  }
}
