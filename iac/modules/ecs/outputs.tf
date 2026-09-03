output "cluster_name" {

  value = aws_ecs_cluster.banking_cluster.name

}

output "cluster_arn" {

  value = aws_ecs_cluster.banking_cluster.arn

}

output "task_definition_arn" {

  value = aws_ecs_task_definition.banking_task.arn

}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.banking_service.name
}

output "service_arn" {
  description = "ECS service ARN"
  value       = aws_ecs_service.banking_service.id
}