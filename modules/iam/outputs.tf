output "APIGWRole_arn" {
  description = "ARN of the IAM role for API Gateway"
  value       = aws_iam_role.APIGWRole.arn
}

output "LambdaRole_arn" {
  description = "ARN of the IAM role for Lambda"
  value       = aws_iam_role.LambdaRole.arn
}
