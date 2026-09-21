module "logging" {
  source = "./modules/logging"

  project_name = var.project_name
  bucket_name  = var.cloudtrail_bucket_name

  account_id = data.aws_caller_identity.current.account_id
  region     = var.home_region
  partition  = data.aws_partition.current.partition
}

module "config" {
  source = "./modules/config"

  project_name = var.project_name
  bucket_name  = var.config_bucket_name
  account_id   = data.aws_caller_identity.current.account_id
}

module "security" {
  source = "./modules/security"
}

module "budget" {
  source = "./modules/budget"

  project_name       = var.project_name
  limit_usd          = var.budget_limit_usd
  notification_email = var.budget_email
}