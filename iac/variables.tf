variable "vpc_cidr" {}
variable "public_subnet_1_cidr" {}
variable "public_subnet_2_cidr" {}
variable "private_subnet_1_cidr" {}
variable "private_subnet_2_cidr" {}
variable "az1" {}
variable "az2" {}
variable "aws_region" {

  description = "AWS Region"

  type = string

}

variable "project_name" {

  description = "Project Name"

  type = string

}

variable "environment" {

  description = "Deployment Environment"

  type = string

}

variable "ssh_cidr" {
  description = "Allowed CIDR for SSH"
  type        = string
}