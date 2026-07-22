variable "project_name" {

  description = "Project Name"

  type        = string

}
 
variable "environment" {

  description = "Environment"

  type        = string

}
 
variable "vpc_id" {

  description = "VPC ID"

  type        = string

}
 
variable "public_subnet_ids" {

  description = "Public Subnet IDs"

  type        = list(string)

}
 
variable "security_group_id" {

  description = "ALB Security Group"

  type        = string

}
 