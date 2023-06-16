resource "aws_iam_user" "service_name" {
  name = "${var.project}-${var.environment}-s3-deployer-${var.service_name}"
  path = "/${var.project}-${var.environment}-s3-deployers/"
}

resource "aws_iam_access_key" "s3-deployer" {
  user = aws_iam_user.service_name.name
}

resource "aws_iam_user_policy" "deployer-policy" {
  name = "${var.project}-${var.environment}-s3-deployer-${var.service_name}-policy"
  user = aws_iam_user.service_name.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "iam:ListRoles",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": "${data.aws_s3_bucket.s3_meta.arn}/*"
        },
        {
            "Action": [
                "cloudfront:CreateInvalidation"
            ],
            "Effect": "Allow",
            "Resource": "${aws_cloudfront_distribution.cdn.arn}"
        }
    ]
}
EOF
}
