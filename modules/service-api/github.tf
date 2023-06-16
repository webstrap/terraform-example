/* SECRETS */

resource "github_actions_secret" "access_key_id" {
  repository = var.repository
  secret_name = "${upper(var.environment)}_AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.deployer.id
}

resource "github_actions_secret" "access_key_secret" {
  repository = var.repository
  secret_name = "${upper(var.environment)}_AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.deployer.secret
}

resource "github_actions_secret" "aws_region" {
  repository = var.repository
  secret_name = "${upper(var.environment)}_AWS_DEFAULT_REGION"
  plaintext_value = var.region
}

resource "github_actions_secret" "service_name" {
  repository = var.repository
  secret_name = "${upper(var.environment)}_SERVICE_NAME"
  plaintext_value = var.service_name
}

resource "github_actions_secret" "full_service_name" {
  repository = var.repository
  secret_name = "${upper(var.environment)}_FULL_SERVICE_NAME"
  plaintext_value = local.full_service_name
}

resource "github_actions_secret" "ecs_cluster" {
  repository = var.repository
  secret_name = "${upper(var.environment)}_ECS_CLUSTER"
  plaintext_value = var.ecs_cluster_name
}

resource "github_actions_secret" "ecr_repo" {
  repository = var.repository
  secret_name = "${upper(var.environment)}_ECR_REPO"
  plaintext_value = aws_ecr_repository.service.name
}

resource "github_actions_secret" "container_name" {
  repository = var.repository
  secret_name = "${upper(var.environment)}_CONTAINER_NAME"
  plaintext_value = local.service_name_with_env
}
