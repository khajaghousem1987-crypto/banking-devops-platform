
resource "aws_lb" "banking_alb" {

  name = "${var.project_name}-${var.environment}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [var.security_group_id]

  subnets = var.public_subnet_ids

  enable_deletion_protection = true
  drop_invalid_header_fields = true
  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = "alb"
    enabled = true
  }
  tags = {

    Name = "${var.project_name}-${var.environment}-alb"

    Environment = var.environment

  }


}


resource "aws_lb_target_group" "banking_tg" {

  name = "${var.project_name}-${var.environment}-tg"

  port = 80

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {

    enabled = true

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    interval = 30

    timeout = 5

    healthy_threshold = 2

    unhealthy_threshold = 2

  }

}
resource "aws_lb_target_group" "green_tg" {
  name        = "${var.project_name}-${var.environment}-green-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-green-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.banking_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}
#################################################
# BLUE/GREEN PRODUCTION LISTENER RULE
#################################################

resource "aws_lb_listener_rule" "production" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.banking_tg.arn
        weight = 1
      }

      target_group {
        arn    = aws_lb_target_group.green_tg.arn
        weight = 0
      }
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  lifecycle {
    ignore_changes = [
      action
    ]
  }
}