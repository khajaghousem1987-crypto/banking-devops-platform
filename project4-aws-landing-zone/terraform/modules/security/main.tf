resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = {
    Name    = "landing-zone-guardduty"
    Purpose = "Threat Detection"
  }
}

resource "aws_securityhub_account" "this" {
  enable_default_standards = true
}