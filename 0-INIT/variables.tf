variable "aws_account_id" {
  description = "The project is limited to this AWS account"
  default     = "111111111111"
}

variable "terraform_user" {
  description = "The user to run Terraform as"
  default     = "terraform"
}

variable "aws_region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "example-terraform-state"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  default     = "example-terraform-lock"
}
