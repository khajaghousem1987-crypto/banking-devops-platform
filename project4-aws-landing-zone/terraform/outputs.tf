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