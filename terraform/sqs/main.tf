resource "aws_sqs_queue" "example_queue" {
  name                      = var.queue_name
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 345600
  visibility_timeout_seconds= 30
}
