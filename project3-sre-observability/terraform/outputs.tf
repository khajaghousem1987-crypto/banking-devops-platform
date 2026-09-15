output "sns_topic_arn" { value=module.sns.topic_arn }
output "application_log_group" { value=module.cloudwatch.application_log_group_name }
output "vpc_flow_log_group" { value=module.vpc_flow_logs.log_group_name }
