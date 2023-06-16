locals {
  services = {
    exampleservice = {
      repository = "exampleservice"

      port   = 5777
      cpu    = 200
      memory = 384

      health_check_path = "/healthcheck"

      redis                        = true
      redis_node_count             = 1
      redis_node_instance_type     = "cache.t4g.micro"
      redis_version                = "5.0.6"
      redis_parameter_group_family = "redis5.0"

      rds                        = true
      rds_mysql_version          = "8.0.28"
      rds_node_instance_type     = "db.t4g.medium"
      rds_node_database_name     = "exampleservice"
      rds_node_storage_size      = 100
      rds_node_storage_type      = "gp2"
      rds_parameter_group_family = "mysql8.0"
      rds_password               = "GENERATE_ME"

      env = [
        {
          name  = "EXAMPLE_PARAM",
          value = "https://exampleservice.${var.route53_zone}"
        },
        {
          name  = "MYSQL_DATABASE",
          value = "exampleservice"
        },
        {
          name  = "SEQUELIZE_POOL_MAX",
          value = "30"
        },
        {
          name  = "DISABLE_APM",
          value = "true"
        }
      ]
    },

    secondexample = {
      repository = "secondexample"

      port   = 3065
      cpu    = 200
      memory = 128

      health_check_path = "/hc"

      redis                        = true
      redis_node_count             = 1
      redis_node_instance_type     = "cache.t4g.micro"
      redis_version                = "5.0.6"
      redis_parameter_group_family = "redis5.0"

      docdb                 = true
      docdb_engine          = var.docdb_engine
      docdb_master_username = var.docdb_master_username
      docdb_master_password = var.docdb_master_password
      docdb_instance_class  = var.docdb_instance_class

      env = [
        {
          name  = "EXAMPLE_SERVICE_URL",
          value = "https://exampleservice.${var.route53_zone}"
        }
      ]
    }
  }
}

module "service_deployments" {
  # creates each.value for each element in the services array
  for_each = local.services

  source = "../modules/service-api"

  alb_front_dns_name = aws_alb.front.dns_name
  alb_front_zone_id = aws_alb.front.zone_id
  ecs_alb_front_arn = aws_alb_listener.front_443.arn

  alb_load_balancing_algorithm = lookup(each.value, "load_balancing_algorithm", "least_outstanding_requests")
  alb_slow_start = lookup(each.value, "slow_start", 0)

  # get the object of the service, use the "ecs_cluster" field or fallback to aws_ecs_cluster.main
  ecs_cluster_id = lookup(each.value, "ecs_cluster", aws_ecs_cluster.main).id
  ecs_cluster_name = lookup(each.value, "ecs_cluster", aws_ecs_cluster.main).name
  ecs_cluster_arn = lookup(each.value, "ecs_cluster", aws_ecs_cluster.main).arn

  repository = each.value.repository

  route53_root_zone_id = local.root_zone_id
  route53_zone = var.route53_zone

  service_instance_count = lookup(each.value, "instance_count", 3)

  service_cpu = each.value.cpu
  service_memory_reservation = each.value.memory

  service_minimum_healthy_percent = lookup(each.value, "service_minimum_healthy_percent", 60)
  service_maximum_percent = lookup(each.value, "service_maximum_percent", 200)

  service_health_check_path = each.value.health_check_path

  service_health_interval = lookup(each.value, "health_interval", 30)
  service_health_timeout = lookup(each.value, "health_timeout", 10)
  service_healthy_threshold = lookup(each.value, "healthy_threshold", 3)
  service_unhealthy_threshold = lookup(each.value, "unhealthy_threshold", 3)

  service_name = each.key
  service_port = each.value.port

  service_redis = lookup(each.value, "redis", false)
  service_redis_node_count = lookup(each.value, "redis_node_count", null)
  service_redis_node_instance_type = lookup(each.value, "redis_node_instance_type", null)
  service_redis_version = lookup(each.value, "redis_version", null)
  service_redis_parameter_group_family = lookup(each.value, "redis_parameter_group_family", null)

  service_rds = lookup(each.value, "rds", false)
  service_rds_mysql_version = lookup(each.value, "rds_mysql_version", null)
  service_rds_node_instance_type = lookup(each.value, "rds_node_instance_type", null)
  service_rds_node_storage_size = lookup(each.value, "rds_node_storage_size", null)
  service_rds_node_storage_type = lookup(each.value, "rds_node_storage_type", null)
  service_rds_node_database_name = lookup(each.value, "rds_node_database_name", null)
  service_rds_parameter_group_family = lookup(each.value, "rds_parameter_group_family", null)
  service_rds_password = lookup(each.value, "rds_password", null)

  service_docdb = lookup(each.value, "docdb", false)
  service_docdb_engine = lookup(each.value, "docdb_engine", null)
  service_docdb_master_username = lookup(each.value, "docdb_master_username", null)
  service_docdb_master_password = lookup(each.value, "docdb_master_password", null)
  service_docdb_instance_class = lookup(each.value, "docdb_instance_class", null)
  service_docdb_engine_version = data.aws_docdb_engine_version.latest.version

  service_env = coalesce(lookup(each.value, "env", null), [])

  additional_security_group_ids = [
    aws_security_group.web.id,
    module.wireguard.vpn_sg_admin_id,
  ]

  ecs_iam_role_arn = local.instance_role

  vpc_id = local.vpc_id
  vpc_cidr = aws_vpc.main.cidr_block

  subnet_ids = local.subnet_ids
  availability_zones = data.aws_availability_zones.available.names

  environment = var.environment
  project = var.project

  depends_on = [
    aws_alb.front
  ]

}
