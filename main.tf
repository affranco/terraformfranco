terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "smx-lab"
  region  = "us-west-2"
}
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "archive_file" "LambdaZipFile" {
  type        = "zip"
  source_file = "${path.module}/src/LambdaFunction.py"
  output_path = "${path.module}/LambdaFunction.zip"
}

resource "aws_iam_role" "APIGWRole" {
  # uncomment the 'permissions_boundary' argument if running this lab on skillmix.io 
  # permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/LabUserNewResourceBoundaryPolicy"
  assume_role_policy = <<POLICY1
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "apigateway.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }
  ]
}
POLICY1
}

resource "aws_iam_policy" "APIGWPolicy" {
  policy = <<POLICY2
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "events:PutEvents"
      ],
      "Resource" : "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/default"
    }
  ]
}
POLICY2
}


resource "aws_iam_role_policy_attachment" "APIGWPolicyAttachment" {
  role       = aws_iam_role.APIGWRole.name
  policy_arn = aws_iam_policy.APIGWPolicy.arn
}

resource "aws_iam_role" "LambdaRole" {
  # uncomment the 'permissions_boundary' argument if running this lab on skillmix.io 
  # permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/LabUserNewResourceBoundaryPolicy"
  assume_role_policy = <<POLICY3
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "lambda.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }
  ]
}
POLICY3
}

resource "aws_iam_policy" "LambdaPolicy" {
  policy = <<POLICY4
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.MyLambdaFunction.function_name}:*:*"
    }
  ]
}
POLICY4
}

resource "aws_iam_role_policy_attachment" "LambdaPolicyAttachment" {
  role       = aws_iam_role.LambdaRole.name
  policy_arn = aws_iam_policy.LambdaPolicy.arn
}

resource "aws_apigatewayv2_api" "MyApiGatewayHTTPApi" {
  name          = "Terraform API Gateway HTTP API to EventBridge"
  protocol_type = "HTTP"
  body = jsonencode(
    {
      "openapi" : "3.0.1",
      "info" : {
        "title" : "API Gateway HTTP API to EventBridge"
      },
      "paths" : {
        "/" : {
          "post" : {
            "responses" : {
              "default" : {
                "description" : "EventBridge response"
              }
            },
            "x-amazon-apigateway-integration" : {
              "integrationSubtype" : "EventBridge-PutEvents",
              "credentials" : "${aws_iam_role.APIGWRole.arn}",
              "requestParameters" : {
                "Detail" : "$request.body.Detail",
                "DetailType" : "MyDetailType",
                "Source" : "demo.apigw"
              },
              "payloadFormatVersion" : "1.0",
              "type" : "aws_proxy",
              "connectionType" : "INTERNET"
            }
          }
        }
      }
  })
}

resource "aws_apigatewayv2_stage" "MyApiGatewayHTTPApiStage" {
  api_id      = aws_apigatewayv2_api.MyApiGatewayHTTPApi.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_cloudwatch_event_rule" "MyEventRule" {
  event_pattern = <<PATTERN
{
  "account": ["${data.aws_caller_identity.current.account_id}"],
  "source": ["demo.apigw"]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "MyRuleTarget" {
  arn  = aws_lambda_function.MyLambdaFunction.arn
  rule = aws_cloudwatch_event_rule.MyEventRule.id
}

resource "aws_cloudwatch_log_group" "MyLogGroup" {
  name              = "/aws/lambda/${aws_lambda_function.MyLambdaFunction.function_name}"
  retention_in_days = 60
}

resource "aws_lambda_function" "MyLambdaFunction" {
  function_name    = "apigw-http-eventbridge-terraform-demo-${data.aws_caller_identity.current.account_id}"
  filename         = data.archive_file.LambdaZipFile.output_path
  source_code_hash = filebase64sha256(data.archive_file.LambdaZipFile.output_path)
  role             = aws_iam_role.LambdaRole.arn
  handler          = "LambdaFunction.lambda_handler"
  runtime          = "python3.9"
  layers           = ["arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPython:15"]
}

resource "aws_lambda_permission" "EventBridgeLambdaPermission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.MyLambdaFunction.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.MyEventRule.arn
}

output "APIGW-URL" {
  value       = aws_apigatewayv2_stage.MyApiGatewayHTTPApiStage.invoke_url
  description = "The API Gateway Invocation URL Queue URL"
}

output "LambdaFunctionName" {
  value       = aws_lambda_function.MyLambdaFunction.function_name
  description = "The Lambda Function name"
}

output "CloudWatchLogName" {
  value       = "/aws/lambda/${aws_lambda_function.MyLambdaFunction.function_name}"
  description = "The Lambda Function Log Group"
}
