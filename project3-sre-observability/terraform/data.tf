data "aws_caller_identity" "current" {}
data "aws_eks_cluster" "existing" { name=var.eks_cluster_name }
