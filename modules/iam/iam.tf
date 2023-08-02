resource "aws_iam_role" "APIGWRole" {
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
