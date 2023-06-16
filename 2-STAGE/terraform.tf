terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    github = {
      source = "hashicorp/github"
    }
    template = {
      source = "hashicorp/template"
    }
    time = {
      source = "hashicorp/time"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
