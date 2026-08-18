module "vpc" {

  source = "./modules/vpc"

  project_name = var.project_name

  vpc_cidr = var.vpc_cidr

  public_subnet_1_cidr = var.public_subnet_1_cidr

  public_subnet_2_cidr = var.public_subnet_2_cidr

  private_subnet_1_cidr = var.private_subnet_1_cidr

  private_subnet_2_cidr = var.private_subnet_2_cidr

  az1 = var.az1

  az2 = var.az2

}
module "security_group" {

  source = "./modules/security-group"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  ssh_cidr = var.ssh_cidr
}

module "iam" {

  source = "./modules/iam"

  project_name = var.project_name

  environment = var.environment

}

module "ecr" {

  source = "./modules/ecr"

  project_name = var.project_name

  environment = var.environment
  #kms_key_arn = module.kms_ecr.key_arn


}

module "cloudwatch" {

  source = "./modules/cloudwatch"

  project_name = var.project_name

  environment = var.environment
  kms_key_arn = module.kms_cloudwatch.key_arn

}
module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  security_group_id  = module.security_group.alb_security_group_id
  access_logs_bucket = module.alb_logs.bucket_name
  depends_on = [
    module.alb_logs
  ]
}

module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_group.ecs_security_group_id

  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn

  # Blue/Green infrastructure role
  infrastructure_role_arn = module.iam.ecs_infrastructure_role_arn

  repository_url = module.ecr.repository_url
  image_tag      = "bootstrap"

  # Current BLUE target group
  target_group_arn = module.alb.target_group_arn

  # Blue/Green configuration
  green_target_group_arn       = module.alb.green_target_group_arn
  production_listener_rule_arn = module.alb.production_listener_rule_arn

  log_group_name = module.cloudwatch.log_group_name

  depends_on = [
    module.iam
  ]
}
module "kms_cloudwatch" {
  source = "./modules/kms"

  project_name = var.project_name
  environment  = var.environment
  purpose      = "cloudwatch"
}

# module "kms_ecr" {
#   source = "./modules/kms"

#   project_name = var.project_name
#   environment  = var.environment
#   purpose      = "ecr"
# }

module "alb_logs" {
  source = "./modules/alb-logs"

  project_name = var.project_name
  environment  = var.environment
}