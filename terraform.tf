terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-mezo"
    key          = "network/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  provider "aws" {
  region     = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
