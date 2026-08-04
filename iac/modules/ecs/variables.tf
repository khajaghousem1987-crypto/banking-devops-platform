variable "project_name" {

  description = "Project Name"

  type = string

}

variable "environment" {

  description = "Environment"

  type = string

}

variable "private_subnet_ids" {

  description = "Private Subnet IDs"

  type = list(string)

}

variable "security_group_id" {

  description = "Security Group ID"

  type = string

}

variable "execution_role_arn" {

  description = "ECS Execution Role ARN"

  type = string

}

variable "task_role_arn" {

  description = "ECS Task Role ARN"

  type = string

}

variable "repository_url" {

  description = "ECR Repository URL"

  type = string

}

variable "target_group_arn" {

  description = "ALB Target Group ARN"

  type = string

}

variable "log_group_name" {

  description = "CloudWatch Log Group"

  type = string

}
 