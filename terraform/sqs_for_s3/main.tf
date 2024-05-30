resource "aws_sqs_queue" "data_queue" {
  name                      = var.queue_name
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 345600
  visibility_timeout_seconds= 30
}

resource "aws_s3_bucket_notification" "new_data" {
  bucket = var.bucket

  queue {
    queue_arn     = aws_sqs_queue.data_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.filter_prefix
  }
}

output "queue_arn" {
  value = aws_sqs_queue.data_queue.arn
}