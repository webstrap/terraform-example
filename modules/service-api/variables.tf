variable "vpc_id" {
  description = "Id of the super VPC."
}

variable "vpc_cidr" {
  description = "CIDR of super VPC."
}

variable "project" {
  description = "Cluster name this service is part of."
}

variable "environment" {
  description = "Used as suffix for resource names."
}

variable "repository" {
  description = "GitHub repository of this project."
}

variable "service_name" {
  description = "Name used for all resources related to this service. Use a name that would also be valid as a domain name."
}

variable "service_port" {
  description = "Container internal port of this service (i.e. 3065 for vortex)."
}

variable "service_instance_count" {
  description = "Amount of instances of this service to maintain."
  default = 3
}

variable "service_minimum_healthy_percent" {
  description = "Percentage of service instances that must at least be healthy for a deployment to happen."
  default = 100
}

variable "service_maximum_percent" {
  description = "Maximum allowed percentage of service instances relative to instance count."
  default = 200
}

variable "service_cpu" {
  description = "Amount of CPU to assign to this service."
}

variable "service_memory_reservation" {
  description = "Amount of memory to reserve to this service."
}

variable "service_health_check_path" {
  description = "Relative URL to use for healthchecks"
}

variable "service_health_interval" {
  description = "Healthcheck interval"
  default = 30
}

variable "service_health_timeout" {
  description = "Healthcheck timeout"
  default = 10
}

variable "service_healthy_threshold" {
  description = "Healthcheck timeout"
  default = 3
}

variable "service_unhealthy_threshold" {
  description = "Healthcheck timeout"
  default = 3
}

variable "service_env" {
  description = "Additional environment variables to include into the service (list -- { name, value })"
  default = []
}

variable "service_redis" {
  description = "Whether an ElasticCache cluster should be created for this service"
  default = false
}

variable "service_redis_node_count" {
  description = "Amount of nodes to create in ECS cluster (i.e. 1)"
}

variable "service_redis_node_instance_type" {
  description = "Type of instance to use for redis cluster (i.e. cache.t2.micro)"
}

variable "service_redis_version" {
  description = "Version of redis to use in cluster (careful, change might trigger recreation!)"
}

variable "service_redis_parameter_group_family" {
  description = "Family of the parameter group to use for this cluster (i.e. redis5.0)"
}

variable "service_rds" {
  description = "Whether this service uses an RDS cluster"
  default = false
}

variable "service_rds_node_instance_type" {
  description = "Type of instance to use for rds cluster (i.e. db.t2.micro)"
}

variable "service_rds_node_storage_type" {
  description = "Type of storage to use for rds cluster (i.e. gp2)"
}

variable "service_rds_node_storage_size" {
  description = "Amount of gigabytes to allocate for each node of this cluster (i.e. 200)"
}

variable "service_rds_node_database_name" {
  description = "Name of the database to create in this cluster (i.e. vortex)"
}

variable "service_rds_mysql_version" {
  description = "Mysql version to be used for this rds cluster (i.e. 8.0.20)"
}

variable "service_rds_password" {
  description = "Password to be used for connections to this RDS cluster"
}

variable "service_rds_parameter_group_family" {
  description = "Family of the parameter group to use for this cluster (i.e. mysql8.0)"
}

variable "service_docdb_engine" {
  description = "Documentdb engine name"
}

variable "service_docdb_master_username" {
  description = "Documentdb username"
}

variable "service_docdb_master_password" {
  description = "Documentdb password"
}

variable "service_docdb_instance_class" {
  description = "Documentdb instance class"
}

variable "service_docdb_engine_version" {
  description = "Documentdb engine version"
}

variable "service_docdb" {
  description = "Whether this service uses an documentdb cluster"
  default = false
}

variable "route53_root_zone_id" {
  description = "Route53 root zone id (aka id of domain)."
}

variable "route53_zone" {
  description = "Route53 root zone name (aka name of domain)."
}

variable "alb_front_dns_name" {
  description = "DNS name of ALB front."
}

variable "alb_front_zone_id" {
  description = "Zone id of ALB front."
}

variable "alb_load_balancing_algorithm" {
  description = "Algorithm to use for balancing out requests"
  default = "least_outstanding_requests"
}

variable "alb_slow_start" {
  description = "Amount of time before application gets hit by full load (up to 30s)"
  default = 0
}

variable "ecs_cluster_id" {
  description = "ECS cluster id for this service."
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster."
}

variable "ecs_cluster_arn" {
  description = "ECS cluster arn for this service."
}

variable "ecs_iam_role_arn" {
  description = "ECS IAM role arn (inherited from super)."
}

variable "ecs_alb_front_arn" {
  description = "ARN of ALB front (usually the TLS listener)."
}

variable "region" {
  default = "eu-central-1"
}

variable "additional_security_group_ids" {
  description = "Ids of additional security group used by resources related to this service (rds, elasticache)"
  default = []
}

variable "subnet_ids" {
  description = "Ids of all subnets used in this cluster"
}

variable "availability_zones" {
  description = "List of available zone names"
}

locals {
  full_service_name = "${var.project}-${var.environment}-${var.service_name}"
  service_name_with_env = "${var.service_name}-${var.environment}"
  route53_fqdn = "${var.service_name}.${var.route53_zone}"
}
