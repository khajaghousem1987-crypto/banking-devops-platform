resource "aws_ebs_volume" "dr_test" {
  availability_zone = "us-east-1a"
  size              = 1
  type              = "gp3"

  tags = {
    Name    = "${local.name_prefix}-dr-test-volume"
    Backup  = "true"
    Purpose = "DR-Recovery-Test"
  }
}