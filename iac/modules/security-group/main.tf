#################################################
# ALB SECURITY GROUP
#################################################

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security Group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

#################################################
# ALB - HTTP INBOUND
#################################################

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow HTTP traffic to ALB"
}

#################################################
# ALB - OUTBOUND
#################################################

resource "aws_vpc_security_group_egress_rule" "alb_outbound" {
  security_group_id = aws_security_group.alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow ALB outbound traffic"
}


#################################################
# ECS TASK SECURITY GROUP
#################################################

resource "aws_security_group" "ecs_task_sg" {
  name        = "${var.project_name}-${var.environment}-ecs-task-sg"
  description = "Security Group for ECS Fargate Tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-task-sg"
    Environment = var.environment
  }
}

#################################################
# ECS - ALLOW PORT 5000 ONLY FROM ALB
#################################################

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id = aws_security_group.ecs_task_sg.id

  referenced_security_group_id = aws_security_group.alb_sg.id

  from_port   = 5000
  to_port     = 5000
  ip_protocol = "tcp"

  description = "Allow application traffic from ALB"
}

#################################################
# ECS - OUTBOUND
#################################################

resource "aws_vpc_security_group_egress_rule" "ecs_outbound" {
  security_group_id = aws_security_group.ecs_task_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow ECS tasks outbound access"
}