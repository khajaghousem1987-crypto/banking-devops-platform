module "sns" { source="./modules/sns" name_prefix="${var.project_name}-${var.environment}" alert_email=var.alert_email }
module "cloudwatch" { source="./modules/cloudwatch" name_prefix="${var.project_name}-${var.environment}" log_retention_days=var.log_retention_days sns_topic_arn=module.sns.topic_arn }
module "vpc_flow_logs" { source="./modules/vpc-flow-logs" name_prefix="${var.project_name}-${var.environment}" vpc_id=var.vpc_id log_retention_days=var.log_retention_days }
