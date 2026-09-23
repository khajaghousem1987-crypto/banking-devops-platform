data "aws_caller_identity" "current" {}

data "aws_region" "primary" {}

data "aws_region" "dr" {
  provider = aws.dr
}