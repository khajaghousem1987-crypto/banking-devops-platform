variable "project_name" {

  description = "Project Name"

  type        = string

}
 
variable "environment" {

  description = "Environment"

  type        = string

}
 
variable "retention_in_days" {

  description = "CloudWatch Log Retention"

  type        = number

  default     = 30

}
 