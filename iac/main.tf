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
 
}

module "cloudwatch" {
 
  source = "./modules/cloudwatch"
 
  project_name = var.project_name
 
  environment = var.environment
 
}

module "alb" {
 
  source = "./modules/alb"
 
  project_name = var.project_name
 
  environment = var.environment
 
  vpc_id = module.vpc.vpc_id
 
  public_subnet_ids = module.vpc.public_subnet_ids
 
  security_group_id = module.security_group.security_group_id
 
}
 