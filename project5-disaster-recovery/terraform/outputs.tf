output "aws_account_id" {
  description = "AWS account used by the DR project"
  value       = data.aws_caller_identity.current.account_id
}

output "primary_region" {
  description = "Primary workload region"
  value       = var.primary_region
}

output "dr_region" {
  description = "Disaster recovery region"
  value       = var.dr_region
}

output "rto_minutes" {
  description = "Target Recovery Time Objective"
  value       = var.rto_minutes
}

output "rpo_minutes" {
  description = "Target Recovery Point Objective"
  value       = var.rpo_minutes
}
output "primary_backup_vault" {
  value = module.backup.primary_vault_name
}

output "primary_backup_vault_arn" {
  value = module.backup.primary_vault_arn
}

output "dr_backup_vault" {
  value = aws_backup_vault.dr.name
}

output "dr_backup_vault_arn" {
  value = aws_backup_vault.dr.arn
}

output "backup_plan_id" {
  value = module.backup.backup_plan_id
}

output "backup_role_arn" {
  value = module.backup.backup_role_arn
}

output "dr_test_volume_id" {
  description = "EBS volume used for Project 5 backup and recovery testing"
  value       = aws_ebs_volume.dr_test.id
}
output "dr_alert_sns_topic_arn" {
  description = "SNS topic for Project 5 DR alerts"
  value       = module.monitoring.sns_topic_arn
}

output "backup_failure_rule" {
  value = module.monitoring.backup_failure_rule_name
}

output "copy_failure_rule" {
  value = module.monitoring.copy_failure_rule_name
}

output "restore_failure_rule" {
  value = module.monitoring.restore_failure_rule_name
}