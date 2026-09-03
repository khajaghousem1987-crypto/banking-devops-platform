resource "aws_ecr_repository" "banking_app" {

  name = "${var.project_name}-${var.environment}-app"

  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {

    scan_on_push = true

  }

  # encryption_configuration {

  #   encryption_type = "KMS"
  #   kms_key         = var.kms_key_arn

  # }

  tags = {

    Name = "${var.project_name}-${var.environment}-ecr"

  }

}

resource "aws_ecr_lifecycle_policy" "banking_app" {

  repository = aws_ecr_repository.banking_app.name

  policy = jsonencode({

    rules = [

      {

        rulePriority = 1

        description = "Keep last 10 images"

        selection = {

          tagStatus = "any"

          countType = "imageCountMoreThan"

          countNumber = 10

        }

        action = {

          type = "expire"

        }

      }

    ]

  })

}