variable "aws_region" { type=string default="us-east-1" }
variable "project_name" { type=string default="banking-sre" }
variable "environment" { type=string default="dev" }
variable "eks_cluster_name" { type=string default="banking-eks-dev-cluster" }
variable "vpc_id" { type=string description="Existing Project 2 VPC" }
variable "alert_email" { type=string default="" }
variable "log_retention_days" { type=number default=30 }
