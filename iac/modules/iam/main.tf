data "aws_iam_policy_document" "ecs_assume_role" {

  statement {

    effect = "Allow"

    actions = [

      "sts:AssumeRole"

    ]

    principals {

      type = "Service"

      identifiers = [

        "ecs-tasks.amazonaws.com"

      ]

    }

  }

}

resource "aws_iam_role" "ecs_execution_role" {

  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {

  role = aws_iam_role.ecs_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}


resource "aws_iam_role" "ecs_task_role" {

  name = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

}

#################################################
# ECS BLUE/GREEN INFRASTRUCTURE ROLE
#################################################

data "aws_iam_policy_document" "ecs_infrastructure_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_infrastructure_role" {
  name = "${var.project_name}-${var.environment}-ecs-infrastructure-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_infrastructure_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-infrastructure-role"
    Environment = var.environment
  }
}

#################################################
# ECS BLUE/GREEN - ALB MANAGEMENT POLICY
#################################################
resource "aws_iam_role_policy_attachment" "ecs_infrastructure_lb_policy" {

  role = aws_iam_role.ecs_infrastructure_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForLoadBalancers"
}