output "alb_arn" {
  value = aws_lb.banking_alb.arn
}

output "alb_dns_name" {
  value = aws_lb.banking_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.banking_tg.arn
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.banking_tg.arn
}

output "green_target_group_arn" {
  value = aws_lb_target_group.green_tg.arn
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}
output "production_listener_rule_arn" {
  value = aws_lb_listener_rule.production.arn
}