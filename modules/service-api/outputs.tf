output "full_service_name" {
  value = local.full_service_name
}

output "ecr_repository" {
  value = aws_ecr_repository.service.repository_url
}

output "service_domain" {
  value = aws_route53_record.service.fqdn
}

output "iam_deployer_key" {
  value = aws_iam_access_key.deployer.id
}

output "iam_deployer_secret" {
  value = aws_iam_access_key.deployer.secret

  sensitive = true
}

output "elasticache_redis_connection" {
  value = (var.service_redis
  ? aws_elasticache_cluster.redis[0].cache_nodes
  : []
  )
}

output "elasticache_rds_connection" {
  value = (var.service_rds
  ? {
    connection = aws_db_instance.mysql[0].address,
    port = aws_db_instance.mysql[0].port,
    password = aws_db_instance.mysql[0].password,
  }
  : {}
  )

  sensitive = true
}

output "env_vars" {
  value = local.ecs_env_vars

  sensitive = true
}

output "meta_vars" {
  value = [
    {
      key = "${upper(var.environment)}_SERVICE_NAME",
      value = var.service_name,
    },
    {
      key = "${upper(var.environment)}_FULL_SERVICE_NAME",
      value = local.full_service_name,
    },
    {
      key = "${upper(var.environment)}_ECS_CLUSTER",
      value = var.ecs_cluster_name,
    },
    {
      key = "${upper(var.environment)}_ECR_REPO",
      value = aws_ecr_repository.service.name,
    },
    {
      key = "${upper(var.environment)}_CONTAINER_NAME",
      value = local.service_name_with_env,
    },
  ]

  sensitive = true
}
