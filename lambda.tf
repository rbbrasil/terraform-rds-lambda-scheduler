data "archive_file" "lambda_rds_scheduler" {
  type        = "zip"
  source_file = "${path.module}/lambda-function/rds-scheduler.py"
  output_path = "${path.module}/lambda-function/rds-scheduler.zip"
}

resource "aws_lambda_function" "lambda_rds_scheduler" {
  function_name = "rds-scheduler-${random_string.random.result}"
  role          = aws_iam_role.lambda_rds_scheduler.arn
  handler       = "rds-scheduler.lambda_handler"
  filename      = data.archive_file.lambda_rds_scheduler.output_path
  runtime       = "python3.8"
  timeout       = 15
}

resource "aws_lambda_permission" "lambda_rds_scheduler_start" {
  statement_id  = "AllowExecutionFromCloudWatchStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_rds_scheduler_start.arn
}

resource "aws_lambda_permission" "lambda_rds_scheduler_stop" {
  statement_id  = "AllowExecutionFromCloudWatchStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rds_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_rds_scheduler_stop.arn
}
