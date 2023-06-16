provider "aws" {
  region              = var.aws_region
  profile             = "example-profile"
  allowed_account_ids = [var.aws_account_id]
}

locals {
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_key" "tfstate_key" {
  description             = "This key is used to encrypt bucket objects in terraform_state"
  deletion_window_in_days = 10
  tags                    = {
    Name = "tfstate_key"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default-ssl" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfstate_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.dynamodb_table_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
