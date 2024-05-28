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
          "s3:PutObject",
          "s3:HeadObject",
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

module "ops-bucket" {
  source = "./s3"
  bucket_name = "mjw-devops"
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
  lambda_zip_file      = "${local.bls_lambda_name}.zip"

  environment_variables = {
    S3_BUCKET_NAME = "your-s3-bucket-name"
    BLS_URL      = "https://download.bls.gov/pub/time.series/pr/" 
  }

  policy = local.bls_lambda_policy
}

output "bls_lambda_function_name" {
  value = module.bls_lambda_function.lambda_function_name
}

output "bls_lambda_function_arn" {
  value = module.bls_lambda_function.lambda_function_arn
}

output "bls_lambda_role_name" {
  value = module.bls_lambda_function.lambda_role_name
}