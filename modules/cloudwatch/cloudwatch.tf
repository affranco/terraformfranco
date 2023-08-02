resource "aws_cloudwatch_event_rule" "MyEventRule" {
  event_pattern = <<PATTERN
{
  "account": ["${data.aws_caller_identity.current.account_id}"],
  "source": ["demo.apigw"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "MyRuleTarget" {
  arn  = var.lambda_function_arn
  rule = aws_cloudwatch_event_rule.MyEventRule.id
}

resource "aws_cloudwatch_log_group" "MyLogGroup" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 60
}
