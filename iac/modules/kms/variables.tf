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