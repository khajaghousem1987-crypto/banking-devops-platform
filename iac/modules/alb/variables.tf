variable "project_name" {

  description = "Project Name"

  type = string

}

variable "environment" {

  description = "Environment"

  type = string

}

variable "vpc_id" {

  description = "VPC ID"

  type = string

}

variable "public_subnet_ids" {

  description = "Public Subnet IDs"

  type = list(string)

}

variable "security_group_id" {

  description = "ALB Security Group"

  type = string

}
variable "access_logs_bucket" {
  description = "S3 bucket used for ALB access logs"
  type        = string
}
 