variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for which flow logs are enabled"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used to encrypt the CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "CloudWatch Flow Log retention period"
  type        = number
  default     = 365
}