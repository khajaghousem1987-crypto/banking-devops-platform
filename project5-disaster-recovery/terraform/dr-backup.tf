resource "aws_backup_vault" "dr" {
  provider = aws.dr

  name = "${local.name_prefix}-dr-vault"

  tags = {
    Purpose = "Cross-Region-DR-Backup"
  }
}