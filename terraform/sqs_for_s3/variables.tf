variable "queue_name" {
  description = "The name of the SQS queue"
  type = string
}

variable "bucket_id" {
  description = "The ID of the bucket being monitored"
  type = string
}

variable "filter_prefix" {
  description = "The filter prefix, if any, being monitored"
  type = string
}