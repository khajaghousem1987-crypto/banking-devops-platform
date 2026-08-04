output "log_group_name" {

  description = "CloudWatch Log Group"

  value = aws_cloudwatch_log_group.ecs_logs.name

}

output "log_group_arn" {

  description = "CloudWatch Log Group ARN"

  value = aws_cloudwatch_log_group.ecs_logs.arn

}
 