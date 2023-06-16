resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true

  default_root_object = "index.html"
  is_ipv6_enabled = true

  comment = "${var.service_name} - ${var.s3_bucket_name}${var.s3_bucket_prefix}"

  http_version = "http2"

  # The cheapest priceclass
  price_class = "PriceClass_All"

  aliases = [
    local.route53_fqdn
  ]

  origin {
    origin_id   = data.aws_s3_bucket.s3_meta.bucket
    domain_name = data.aws_s3_bucket.s3_meta.bucket_domain_name
    origin_path = var.s3_bucket_prefix
  }

  custom_error_response {
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_bucket_name

    forwarded_values {
      query_string = false

      headers = [
        "Origin",
        "Access-Control-Request-Method",
        "Access-Control-Request-Headers",
      ]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.cf_min_ttl
    default_ttl            = var.cf_default_ttl
    max_ttl                = var.cf_max_ttl

    compress = true
  }

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.cf_acm_cert
    ssl_support_method = "sni-only"
  }

  wait_for_deployment = false
}
