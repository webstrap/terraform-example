resource "aws_ecr_repository" "service" {
  name = local.full_service_name
  image_tag_mutability = "MUTABLE"
  force_delete = false

  image_scanning_configuration {
    scan_on_push = false
  }
}
