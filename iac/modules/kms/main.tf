data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "kms" {

  # Allow account administration of the key
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  # CloudWatch Logs permission - only for CloudWatch key
  dynamic "statement" {

    for_each = var.log_group_name != null ? [1] : []

    content {
      sid    = "AllowCloudWatchLogs"
      effect = "Allow"

      principals {
        type = "Service"
        identifiers = [
          "logs.${data.aws_region.current.region}.amazonaws.com"
        ]
      }

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]

      resources = ["*"]

      condition {
        test     = "ArnEquals"
        variable = "kms:EncryptionContext:aws:logs:arn"

        values = [
          "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.log_group_name}"
        ]
      }
    }
  }
}
resource "aws_kms_key" "this" {
  description             = "KMS key for ${var.project_name}-${var.environment}-${var.purpose}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-${var.purpose}-kms"
    Environment = var.environment
    Purpose     = var.purpose
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.project_name}-${var.environment}-${var.purpose}"
  target_key_id = aws_kms_key.this.key_id
}