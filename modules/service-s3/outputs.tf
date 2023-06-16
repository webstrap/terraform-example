output "cf-dist" {
  value = {
    id = aws_cloudfront_distribution.cdn.id
    url = aws_cloudfront_distribution.cdn.domain_name
  }
}

output "r53" {
  value = aws_route53_record.service
}

output "s3" {
  value = {
    bucket = var.s3_bucket_name
    prefix = var.s3_bucket_prefix
  }
}

output "iam" {
  value = {
    iam_id = aws_iam_access_key.s3-deployer.id
    user = aws_iam_user.service_name.name
  }
}
