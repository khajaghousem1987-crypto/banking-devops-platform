variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "notification_email" {
  description = "Optional email address for DR alerts"
  type        = string
  default     = ""
  sensitive   = true
}