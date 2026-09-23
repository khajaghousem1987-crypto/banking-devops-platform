variable "project_name" {
  description = "Project name used for naming and tagging"
  type        = string
  default     = "banking-dr"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "dr_region" {
  description = "Disaster recovery AWS region"
  type        = string
  default     = "us-west-2"
}

variable "rto_minutes" {
  description = "Target Recovery Time Objective in minutes"
  type        = number
  default     = 30
}

variable "rpo_minutes" {
  description = "Target Recovery Point Objective in minutes"
  type        = number
  default     = 15
}

variable "notification_email" {
  description = "Optional email for DR notifications"
  type        = string
  default     = ""
  sensitive   = true
}