terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
  backend "s3" {
    bucket = "mjw-devops"
    key = "terraform.tfstate"
  }
}
provider "aws" {
  region  = var.region
}

module "ops-bucket" {
  source = "./s3"
  bucket_name = "mjw-devops"
}

module "data_bucket" {
  source = "./s3"
  bucket_name = "mjw-cloudquest-bls-data"
  block_public_access = false
}