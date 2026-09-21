output "organization_id" {
  value = data.aws_organizations_organization.current.id
}

output "organization_root_id" {
  value = local.root_id
}

output "security_ou_id" {
  value = module.security_ou.id
}

output "infrastructure_ou_id" {
  value = module.infrastructure_ou.id
}

output "workloads_ou_id" {
  value = module.workloads_ou.id
}

output "development_ou_id" {
  value = module.development_ou.id
}

output "uat_ou_id" {
  value = module.uat_ou.id
}

output "production_ou_id" {
  value = module.production_ou.id
}
output "development_security_scp_id" {
  value = module.development_security_scp.policy_id
}
output "cloudtrail_name" {
  value = module.logging.trail_name
}

output "cloudtrail_bucket_name" {
  value = module.logging.bucket_name
}

output "config_bucket_name" {
  value = module.config.bucket_name
}

output "config_recorder_name" {
  value = module.config.recorder_name
}

output "guardduty_detector_id" {
  value = module.security.guardduty_detector_id
}

output "security_hub_enabled" {
  value = module.security.security_hub_enabled
}

output "budget_name" {
  value = module.budget.budget_name
}