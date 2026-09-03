output "flow_log_id" {
  description = "VPC Flow Log ID"
  value       = aws_flow_log.this.id
}

output "log_group_name" {
  description = "CloudWatch Log Group used by VPC Flow Logs"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "iam_role_arn" {
  description = "IAM role used by VPC Flow Logs"
  value       = aws_iam_role.vpc_flow_logs.arn
}