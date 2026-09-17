data "aws_organizations_organization" "current" {}

locals {
  root_id = data.aws_organizations_organization.current.roots[0].id
}

module "security_ou" {
  source = "./modules/organizational-unit"

  name      = "Security"
  parent_id = local.root_id
}

module "infrastructure_ou" {
  source = "./modules/organizational-unit"

  name      = "Infrastructure"
  parent_id = local.root_id
}

module "workloads_ou" {
  source = "./modules/organizational-unit"

  name      = "Workloads"
  parent_id = local.root_id
}

module "development_ou" {
  source = "./modules/organizational-unit"

  name      = "Development"
  parent_id = module.workloads_ou.id
}

module "uat_ou" {
  source = "./modules/organizational-unit"

  name      = "UAT"
  parent_id = module.workloads_ou.id
}

module "production_ou" {
  source = "./modules/organizational-unit"

  name      = "Production"
  parent_id = module.workloads_ou.id
}