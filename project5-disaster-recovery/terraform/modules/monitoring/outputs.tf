output "sns_topic_arn" {
  description = "SNS topic used for DR alerts"
  value       = aws_sns_topic.dr_alerts.arn
}

output "backup_failure_rule_name" {
  value = aws_cloudwatch_event_rule.backup_failed.name
}

output "copy_failure_rule_name" {
  value = aws_cloudwatch_event_rule.copy_failed.name
}

output "restore_failure_rule_name" {
  value = aws_cloudwatch_event_rule.restore_failed.name
}