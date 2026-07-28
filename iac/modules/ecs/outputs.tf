output "cluster_name" {
 
  value = aws_ecs_cluster.banking_cluster.name
 
}
 
output "cluster_arn" {
 
  value = aws_ecs_cluster.banking_cluster.arn
 
}