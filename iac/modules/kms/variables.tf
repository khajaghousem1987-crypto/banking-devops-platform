variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "purpose" {
  description = "Purpose of the KMS key, for example cloudwatch or ecr"
  type        = string
}
variable "log_group_name" {
  description = "CloudWatch Log Group name allowed to use this KMS key"
  type        = string
  default     = null
}