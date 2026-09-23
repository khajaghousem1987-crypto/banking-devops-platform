resource "aws_sns_topic" "dr_alerts" {
  name = "${var.project_name}-${var.environment}-dr-alerts"

  tags = {
    Purpose = "DR-Monitoring"
  }
}

resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.dr_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# ---------------------------------------------------------
# Backup Job Failure
# ---------------------------------------------------------

resource "aws_cloudwatch_event_rule" "backup_failed" {
  name        = "${var.project_name}-${var.environment}-backup-failed"
  description = "Detect failed AWS Backup jobs"

  event_pattern = jsonencode({
    source = [
      "aws.backup"
    ]

    detail-type = [
      "Backup Job State Change"
    ]

    detail = {
      state = [
        "FAILED",
        "ABORTED",
        "EXPIRED"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "backup_failed_sns" {
  rule      = aws_cloudwatch_event_rule.backup_failed.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.dr_alerts.arn
}

# ---------------------------------------------------------
# Copy Job Failure
# ---------------------------------------------------------

resource "aws_cloudwatch_event_rule" "copy_failed" {
  name        = "${var.project_name}-${var.environment}-copy-failed"
  description = "Detect failed AWS Backup cross-region copy jobs"

  event_pattern = jsonencode({
    source = [
      "aws.backup"
    ]

    detail-type = [
      "Copy Job State Change"
    ]

    detail = {
      state = [
        "FAILED"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "copy_failed_sns" {
  rule      = aws_cloudwatch_event_rule.copy_failed.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.dr_alerts.arn
}

# ---------------------------------------------------------
# Restore Job Failure
# ---------------------------------------------------------

resource "aws_cloudwatch_event_rule" "restore_failed" {
  name        = "${var.project_name}-${var.environment}-restore-failed"
  description = "Detect failed AWS Backup restore jobs"

  event_pattern = jsonencode({
    source = [
      "aws.backup"
    ]

    detail-type = [
      "Restore Job State Change"
    ]

    detail = {
      state = [
        "FAILED",
        "ABORTED"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "restore_failed_sns" {
  rule      = aws_cloudwatch_event_rule.restore_failed.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.dr_alerts.arn
}

# ---------------------------------------------------------
# Allow EventBridge to publish to SNS
# ---------------------------------------------------------

data "aws_iam_policy_document" "sns_policy" {
  statement {
    sid    = "AllowEventBridgePublish"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "events.amazonaws.com"
      ]
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      aws_sns_topic.dr_alerts.arn
    ]
  }
}

resource "aws_sns_topic_policy" "dr_alerts" {
  arn    = aws_sns_topic.dr_alerts.arn
  policy = data.aws_iam_policy_document.sns_policy.json
}