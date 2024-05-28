variable "region" {
  description = "The AWS region where resources will be created."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "lambda_zip_file" {
  description = "The path to the Lambda function deployment package."
  type        = string
}

variable "policy" {
  description = "The IAM policy to attach to the Lambda function's role."
  type        = string
}

variable "environment_variables" {
  description = "A map of environment variables for the Lambda function."
  type        = map(string)
}
