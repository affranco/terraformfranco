resource "aws_lambda_function" "MyLambdaFunction" {
  function_name    = "apigw-http-eventbridge-terraform-demo-${data.aws_caller_identity.current.account_id}"
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  role             = var.LambdaRole_arn
  handler          = "LambdaFunction.lambda_handler"
  runtime          = "python3.9"
  layers           = ["arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPython:15"]
}

resource "aws_lambda_permission" "EventBridgeLambdaPermission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.MyLambdaFunction.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.MyEventRule_arn
}
