# This restricts access to the bucket to only the terraform user
# and denies access to anyone else.
# Comment it out if you want to allow access to other users.
data "aws_iam_policy_document" "access_for_terraform_user" {
  dynamic "statement" {
    for_each = ["Allow", "Deny"]
    content {
      effect     = statement.value
      principals {
        type        = "AWS"
        identifiers = [
          "arn:aws:iam::${var.aws_account_id}:user/${var.terraform_user}"
        ]
      }
      actions = [
        "s3:*",
      ]

      resources = [
        local.bucket_arn,
        "${local.bucket_arn}/*",
      ]

      not_principals {
        identifiers = ["arn:aws:iam::${var.aws_account_id}:user/${var.terraform_user}"]
        type        = "AWS"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "access_for_terraform_user" {
  bucket = aws_s3_bucket.terraform_state.bucket
  policy = data.aws_iam_policy_document.access_for_terraform_user.json
}
