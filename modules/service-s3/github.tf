resource "github_actions_secret" "access_key_id" {
  count = local.create_github_resources ? 1 : 0

  repository       = var.repository
  secret_name      = "${upper(var.environment)}_AWS_ACCESS_KEY_ID"
  plaintext_value  = aws_iam_access_key.s3-deployer.id
}

resource "github_actions_secret" "access_key_secret" {
  count = local.create_github_resources ? 1 : 0

  repository       = var.repository
  secret_name      = "${upper(var.environment)}_AWS_SECRET_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.s3-deployer.secret
}

resource "github_actions_secret" "aws_region" {
  count = local.create_github_resources ? 1 : 0

  repository       = var.repository
  secret_name      = "${upper(var.environment)}_AWS_DEFAULT_REGION"
  plaintext_value  = var.region
}

resource "github_actions_secret" "bucket_name" {
  count = local.create_github_resources ? 1 : 0

  repository       = var.repository
  secret_name      = "${upper(var.environment)}_AWS_S3_BUCKET_NAME"
  plaintext_value  = data.aws_s3_bucket.s3_meta.bucket
}

resource "github_actions_secret" "aws_cloudfront_dist" {
  count = local.create_github_resources ? 1 : 0

  repository       = var.repository
  secret_name      = "${upper(var.environment)}_AWS_CLOUDFRONT_DISTRIBUTION"
  plaintext_value  = aws_cloudfront_distribution.cdn.id
}

resource "github_actions_secret" "aws_cloudfront_fqdn" {
  count = local.create_github_resources ? 1 : 0

  repository       = var.repository
  secret_name      = "${upper(var.environment)}_AWS_CLOUDFRONT_FQDN"
  plaintext_value  = local.route53_fqdn
}

resource "github_actions_secret" "service_name" {
  count = local.create_github_resources ? 1 : 0

  repository       = var.repository
  secret_name      = "${upper(var.environment)}_SERVICE_NAME"
  plaintext_value  = var.service_name
}
