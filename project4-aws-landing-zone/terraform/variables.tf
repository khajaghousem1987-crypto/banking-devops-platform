variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "banking-landing-zone"
}

variable "home_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cloudtrail_bucket_name" {
  description = "Globally unique S3 bucket for CloudTrail logs"
  type        = string
}

variable "config_bucket_name" {
  description = "Globally unique S3 bucket for AWS Config"
  type        = string
}

variable "budget_limit_usd" {
  description = "Monthly AWS budget in USD"
  type        = number
  default     = 100
}

variable "budget_email" {
  description = "Email address for AWS Budget notifications"
  type        = string
  default     = ""
  sensitive   = true
}