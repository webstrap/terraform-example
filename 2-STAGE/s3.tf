resource "aws_s3_bucket" "main" {
  bucket = "${var.project}-${var.environment}-main"

  tags = {
    Name = var.project
    Group = var.project
  }
  force_destroy = false
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = "${var.project}-${var.environment}-main"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "GET", "HEAD"
    ]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = "${var.project}-${var.environment}-main"

  acl = "public-read"
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = "${var.project}-${var.environment}-main"

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "prophet-policy" {
  bucket = aws_s3_bucket.main.bucket
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "${aws_s3_bucket.main.arn}/*"
            ]
        }
    ]
}
POLICY
}
