############################################
# CloudWatch Log Group
############################################

resource "aws_cloudwatch_log_group" "ecs_logs" {

  name = "/ecs/${var.project_name}-${var.environment}"

  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn

  tags = {

    Name = "${var.project_name}-${var.environment}-logs"

    Environment = var.environment

  }

}
 