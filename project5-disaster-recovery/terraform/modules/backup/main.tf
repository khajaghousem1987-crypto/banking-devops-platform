resource "aws_backup_vault" "primary" {
  name = "${var.project_name}-${var.environment}-primary-vault"

  tags = {
    Purpose = "Primary-Backup"
  }
}

resource "aws_iam_role" "backup" {
  name = "${var.project_name}-${var.environment}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "backup.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role = aws_iam_role.backup.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role = aws_iam_role.backup.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "this" {
  name = "${var.project_name}-${var.environment}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.primary.name

    schedule = "cron(0 5 * * ? *)"

    lifecycle {
      delete_after = 7
    }

    copy_action {
      destination_vault_arn = var.dr_vault_arn

      lifecycle {
        delete_after = 7
      }
    }
  }

  tags = {
    Purpose = "Disaster-Recovery"
  }
}

resource "aws_backup_selection" "tagged_resources" {
  name         = "${var.project_name}-${var.environment}-selection"
  plan_id      = aws_backup_plan.this.id
  iam_role_arn = aws_iam_role.backup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }
}