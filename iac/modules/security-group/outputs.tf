output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

output "ecs_security_group_id" {
  description = "ECS Task Security Group ID"
  value       = aws_security_group.ecs_task_sg.id
}