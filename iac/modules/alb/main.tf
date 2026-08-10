
resource "aws_lb" "banking_alb" {

  name = "${var.project_name}-${var.environment}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [var.security_group_id]

  subnets = var.public_subnet_ids

  enable_deletion_protection = false

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
    timeout              = 5
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

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.banking_tg.arn

  }

}
  