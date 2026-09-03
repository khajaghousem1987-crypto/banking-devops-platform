output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "alb_dns_name" {

  value = module.alb.alb_dns_name

}

output "blue_target_group_arn" {
  value = module.alb.blue_target_group_arn
}

output "green_target_group_arn" {
  value = module.alb.green_target_group_arn
}

output "listener_arn" {
  value = module.alb.listener_arn
}

output "ecs_cluster_name" {

  value = module.ecs.cluster_name

}

output "task_definition_arn" {

  value = module.ecs.task_definition_arn

}

