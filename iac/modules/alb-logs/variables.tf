variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days ALB access logs are retained"
  type        = number
  default     = 365
}

variable "noncurrent_version_retention_days" {
  description = "Number of days non-current S3 object versions are retained"
  type        = number
  default     = 30
}