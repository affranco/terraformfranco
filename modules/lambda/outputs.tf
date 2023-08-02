output "LambdaFunctionName" {
  value       = aws_lambda_function.MyLambdaFunction.function_name
  description = "The Lambda Function name"
}
