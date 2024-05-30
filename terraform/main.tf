locals {
  data_bucket_name = "mjw-cloudquest-bls-data"
  bls_lambda_name  = "get_bls_data"
  all_data_lambda_name = "get_all_data"
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
  pop_lambda_name = "get_datausa_pop"
  pop_lambda_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
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
  report_lambda_name = "get_reports"
  report_lambda_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:GetObject",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = module.data_queue.queue_arn,
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
    key    = "terraform.tfstate"
  }
}
provider "aws" {
  region = var.region
}

data "aws_s3_bucket" "ops_bucket" {
  bucket = "mjw-devops"
}

module "data_bucket" {
  source              = "./s3"
  bucket_name         = local.data_bucket_name
  block_public_access = false
}

module "bls_lambda_function" {
  source               = "./lambda"
  region               = var.region
  lambda_function_name = local.bls_lambda_name
  lambda_zip_file      = "../${local.bls_lambda_name}/${local.bls_lambda_name}.zip"
  timeout              = 300

  environment_variables = {
    S3_BUCKET_NAME = local.data_bucket_name
    BLS_URL        = "https://download.bls.gov"
  }

  policy = local.bls_lambda_policy
}

module "pop_lambda_function" {
  source               = "./lambda"
  region               = var.region
  lambda_function_name = local.pop_lambda_name
  lambda_zip_file      = "../${local.pop_lambda_name}/${local.pop_lambda_name}.zip"

  environment_variables = {
    API_URL   = "https://datausa.io/api/data?drilldowns=Nation&measures=Population"
    S3_BUCKET = local.data_bucket_name
  }

  policy = local.pop_lambda_policy
}

module "report_instance" {
  source = "./sagemaker"
  instance_name = "pop-data-report"
}

module "all_data_lambda_function" {
  source               = "./lambda"
  region               = var.region
  lambda_function_name = local.all_data_lambda_name
  lambda_zip_file      = "../${local.all_data_lambda_name}/${local.all_data_lambda_name}.zip"

  environment_variables = {
    API_URL   = "https://datausa.io/api/data?drilldowns=Nation&measures=Population"
    S3_BUCKET_NAME = local.data_bucket_name
    BLS_URL        = "https://download.bls.gov"
  }

  policy = local.bls_lambda_policy
}

module "all_data_schedule" {
  source = "./scheduler"
  lambda_arn = module.all_data_lambda_function.lambda_arn
  lambda_name = local.all_data_lambda_name
}


module "data_queue" {
  source = "./sqs_for_s3"
  queue_name = "data_monitoring"
  bucket_id = module.data_bucket.bucket_id
  filter_prefix = "pop_data/"
}

module "report_lambda_function" {
  source               = "./lambda"
  region               = var.region
  lambda_function_name = local.report_lambda_name
  lambda_zip_file      = "../${local.report_lambda_name}/${local.report_lambda_name}.zip"

  environment_variables = {
    S3_BUCKET_NAME = local.data_bucket_name
  }

  policy = local.report_lambda_policy
}

resource "aws_lambda_event_source_mapping" "report_lambda_trigger" {
  event_source_arn = module.data_queue.queue_arn
  function_name    = module.report_lambda_function.lambda_arn
  batch_size       = 1
  enabled          = true
}