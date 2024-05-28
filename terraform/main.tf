locals {
  data_bucket_name = "mjw-cloudquest-bls-data"
  bls_lambda_name = "get_bls_data"
  bls_lambda_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${local.data_bucket_name}",
          "arn:aws:s3:::${local.data_bucket_name}/*",
        ],
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "*",
      },
    ],
  })
}

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

data "aws_s3_bucket" "ops_bucket" {
  bucket = "mjw-devops"
}

module "data_bucket" {
  source = "./s3"
  bucket_name = local.data_bucket_name
  block_public_access = false
}

module "bls_lambda_function" {
  source               = "./lambda" 
  region               = var.region  
  lambda_function_name = local.bls_lambda_name
  lambda_zip_file      = "../${local.bls_lambda_name}/${local.bls_lambda_name}.zip"
  timeout = 300

  environment_variables = {
    S3_BUCKET_NAME = local.data_bucket_name
    BLS_URL      = "https://download.bls.gov" 
  }

  policy = local.bls_lambda_policy
}
