locals {
  ecs_service_cloudwatch_log_group = "${var.project}-${var.environment}-${var.service_name}"

  ecs_env_vars_dynamic = [
    {
      name = "REDIS_HOST",
      value = var.service_redis ? aws_elasticache_cluster.redis[0].cache_nodes[0].address : "",
    },

    {
      name = "REDIS_PORT",
      value = var.service_redis ? aws_elasticache_cluster.redis[0].cache_nodes[0].port : "",
    },

    {
      name = "MYSQL_HOST",
      value = var.service_rds ? aws_db_instance.mysql[0].address : "",
    },

    {
      name = "MYSQL_PORT",
      value = var.service_rds ? aws_db_instance.mysql[0].port : "",
    },

    {
      name = "MYSQL_USER",
      value = var.service_rds ? aws_db_instance.mysql[0].username : "",
    },

    {
      name = "MYSQL_PASSWORD",
      value = var.service_rds ? aws_db_instance.mysql[0].password : "",
    },

    {
      name = "DOCDB_DB_HOSTNAME",
      value = var.service_docdb ? aws_docdb_cluster_instance.docdb[0].endpoint : "",
    },

    {
      name = "ENV",
      value = var.environment,
    },

    {
      name = "NODE_ENV",
      value = var.environment,
    },

    {
      name = "SELF_HOST",
      value = local.route53_fqdn,
    },
  ]

  ecs_env_vars = concat(var.service_env, local.ecs_env_vars_dynamic)
}

resource "aws_cloudwatch_log_group" "service-loggroup" {
  name = local.ecs_service_cloudwatch_log_group
  # consider GDPR when extending log retention
  retention_in_days = 90
}

resource "aws_ecs_task_definition" "service" {
  family = local.full_service_name

  container_definitions = templatefile("${path.module}/files/task-definitions/service.json", {
    region = var.region
    project = var.project
    environment = var.environment

    environment_variables = jsonencode(local.ecs_env_vars)

    service_name = var.service_name
    service_port = var.service_port
    service_cpu = var.service_cpu
    service_memory_reservation = var.service_memory_reservation

    ecr_repository = aws_ecr_repository.service.repository_url

    cloudwatch_log_group = local.ecs_service_cloudwatch_log_group
  })
}

resource "aws_ecs_service" "service" {
  name = var.service_name
  cluster = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.service.arn

  force_new_deployment = true

  desired_count = var.service_instance_count
  deployment_minimum_healthy_percent = var.service_minimum_healthy_percent
  deployment_maximum_percent = var.service_maximum_percent

  iam_role = var.ecs_iam_role_arn

  load_balancer {
    target_group_arn = aws_alb_target_group.service_tg.arn
    container_name = local.service_name_with_env
    container_port = var.service_port
  }
}
