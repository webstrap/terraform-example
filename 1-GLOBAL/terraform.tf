terraform {
  required_providers {
    aws = {
      # You should upgrade the version from time to time
      source = "hashicorp/aws"
      version = "5.4.0"
    }
  }
  required_version = ">= 0.13"
}
