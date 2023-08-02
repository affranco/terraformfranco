output "CloudWatchLogName" {
  value       = aws_cloudwatch_log_group.MyLogGroup.name
  description = "The Lambda Function Log Group"
}
