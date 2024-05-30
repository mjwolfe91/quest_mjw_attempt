resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.lambda_name}_schedule"
  schedule_expression = "cron(0 8 * * ? *)" # hardcoded for simplicity
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "InvokeLambdaFunction"

  arn = var.lambda_arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.lambda_schedule.arn
}