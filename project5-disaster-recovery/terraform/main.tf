locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "backup" {
  source = "./modules/backup"

  project_name = var.project_name
  environment  = var.environment

  dr_vault_arn = aws_backup_vault.dr.arn
}
