variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "dr_vault_arn" {
  description = "ARN of the backup vault in the DR region"
  type        = string
}